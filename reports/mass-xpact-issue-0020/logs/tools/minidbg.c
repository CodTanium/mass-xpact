/* minidbg.exe <out.txt> <program> [arguments...]
   Runs the program under the Win32 debug API (this process only) and, for every access violation,
   writes the exception address and a stack (StackWalk64) as module!+rva lines. */
#include <windows.h>
#include <dbghelp.h>
#include <stdio.h>
#include <string.h>

typedef struct { DWORD64 base; DWORD size; char name[64]; } Mod;
static Mod mods[512]; static int nmods;
static HANDLE proc;

static void add_mod(HANDLE file, DWORD64 base) {
  char path[MAX_PATH] = "?";
  if (file && GetFinalPathNameByHandleA(file, path, MAX_PATH, 0) == 0) strcpy(path, "?");
  const char *n = strrchr(path, '\\'); n = n ? n + 1 : path;
  IMAGE_DOS_HEADER dos; IMAGE_NT_HEADERS64 nt; SIZE_T rd;
  DWORD size = 0;
  if (ReadProcessMemory(proc, (LPCVOID)base, &dos, sizeof dos, &rd) &&
      ReadProcessMemory(proc, (LPCVOID)(base + dos.e_lfanew), &nt, sizeof nt, &rd))
    size = nt.OptionalHeader.SizeOfImage;
  if (nmods < 512) { mods[nmods].base = base; mods[nmods].size = size; strncpy(mods[nmods].name, n, 63); nmods++; }
}
static void where(FILE *o, DWORD64 a) {
  for (int i = 0; i < nmods; i++)
    if (a >= mods[i].base && a < mods[i].base + mods[i].size) { fprintf(o, "  %s+%llx\n", mods[i].name, a - mods[i].base); return; }
  fprintf(o, "  ?%llx\n", a);
}

/* Append one argument to cmd, quoted by the rules CommandLineToArgvW and the MSVC runtime use,
   so an argument can never split into several or end the quoting early. Returns 0 if it does not fit. */
static int append_arg(char *cmd, size_t cap, size_t *len, const char *arg) {
  size_t n = *len;
  #define PUT(ch) do { if (n + 1 >= cap) return 0; cmd[n++] = (ch); } while (0)
  if (n > 0) PUT(' ');
  PUT('"');
  for (const char *p = arg; ; p++) {
    size_t slashes = 0;
    while (*p == '\\') { slashes++; p++; }
    if (*p == '\0') { for (size_t k = 0; k < 2 * slashes; k++) PUT('\\'); break; }   /* before the closing quote */
    if (*p == '"') { for (size_t k = 0; k < 2 * slashes + 1; k++) PUT('\\'); PUT('"'); }
    else { for (size_t k = 0; k < slashes; k++) PUT('\\'); PUT(*p); }
  }
  PUT('"');
  #undef PUT
  cmd[n] = '\0'; *len = n;
  return 1;
}

int main(int argc, char **argv) {
  if (argc < 3) { fprintf(stderr, "usage: minidbg.exe <out.txt> <program> [arguments...]\n"); return 2; }

  /* The program is started by its full path (lpApplicationName), never looked up through a shell
     or re-parsed from the command line. It must be an existing file. */
  char app[MAX_PATH];
  DWORD got = SearchPathA(NULL, argv[2], ".exe", MAX_PATH, app, NULL);
  if (got == 0 || got >= MAX_PATH) { fprintf(stderr, "program not found: %s\n", argv[2]); return 2; }
  DWORD attr = GetFileAttributesA(app);
  if (attr == INVALID_FILE_ATTRIBUTES || (attr & FILE_ATTRIBUTE_DIRECTORY)) { fprintf(stderr, "not a program file: %s\n", app); return 2; }

  static char cmd[32768]; size_t len = 0;
  cmd[0] = '\0';
  if (!append_arg(cmd, sizeof cmd, &len, app)) { fprintf(stderr, "command line too long\n"); return 2; }
  for (int i = 3; i < argc; i++)
    if (!append_arg(cmd, sizeof cmd, &len, argv[i])) { fprintf(stderr, "command line too long\n"); return 2; }

  FILE *o = fopen(argv[1], "w");
  if (!o) { fprintf(stderr, "cannot write %s\n", argv[1]); return 2; }
  STARTUPINFOA si = { sizeof si }; PROCESS_INFORMATION pi;
  if (!CreateProcessA(app, cmd, NULL, NULL, FALSE, DEBUG_ONLY_THIS_PROCESS, NULL, NULL, &si, &pi)) { printf("CreateProcess failed %lu\n", GetLastError()); return 2; }
  proc = pi.hProcess;
  SymInitialize(proc, NULL, FALSE);
  HANDLE threads[4096]; DWORD tids[4096]; int nth = 0;
  DEBUG_EVENT ev; int av = 0; DWORD exit_code = 0;
  for (;;) {
    if (!WaitForDebugEvent(&ev, INFINITE)) break;
    DWORD cont = DBG_CONTINUE;
    switch (ev.dwDebugEventCode) {
    case CREATE_PROCESS_DEBUG_EVENT:
      add_mod(ev.u.CreateProcessInfo.hFile, (DWORD64)ev.u.CreateProcessInfo.lpBaseOfImage);
      SymLoadModuleEx(proc, ev.u.CreateProcessInfo.hFile, NULL, NULL, (DWORD64)ev.u.CreateProcessInfo.lpBaseOfImage, 0, NULL, 0);
      threads[nth] = ev.u.CreateProcessInfo.hThread; tids[nth++] = ev.dwThreadId; break;
    case CREATE_THREAD_DEBUG_EVENT:
      if (nth < 4096) { threads[nth] = ev.u.CreateThread.hThread; tids[nth++] = ev.dwThreadId; } break;
    case LOAD_DLL_DEBUG_EVENT:
      add_mod(ev.u.LoadDll.hFile, (DWORD64)ev.u.LoadDll.lpBaseOfDll);
      SymLoadModuleEx(proc, ev.u.LoadDll.hFile, NULL, NULL, (DWORD64)ev.u.LoadDll.lpBaseOfDll, 0, NULL, 0);
      break;
    case EXCEPTION_DEBUG_EVENT: {
      EXCEPTION_RECORD *er = &ev.u.Exception.ExceptionRecord;
      if (er->ExceptionCode == EXCEPTION_BREAKPOINT) break;
      cont = DBG_EXCEPTION_NOT_HANDLED;
      if (er->ExceptionCode != EXCEPTION_ACCESS_VIOLATION) break;
      av++;
      fprintf(o, "AV %d first_chance=%lu at", av, ev.u.Exception.dwFirstChance); where(o, (DWORD64)er->ExceptionAddress);
      fprintf(o, " %s address %llx\n", er->ExceptionInformation[0] ? "write" : "read", (unsigned long long)er->ExceptionInformation[1]);
      HANDLE th = NULL;
      for (int i = 0; i < nth; i++) if (tids[i] == ev.dwThreadId) th = threads[i];
      CONTEXT c; c.ContextFlags = CONTEXT_FULL;
      if (th && GetThreadContext(th, &c)) {
        fprintf(o, " rax=%llx rbx=%llx rcx=%llx rdx=%llx rsi=%llx rdi=%llx r8=%llx r9=%llx\n", c.Rax, c.Rbx, c.Rcx, c.Rdx, c.Rsi, c.Rdi, c.R8, c.R9);
        STACKFRAME64 f = {0};
        f.AddrPC.Offset = c.Rip; f.AddrPC.Mode = AddrModeFlat;
        f.AddrFrame.Offset = c.Rbp; f.AddrFrame.Mode = AddrModeFlat;
        f.AddrStack.Offset = c.Rsp; f.AddrStack.Mode = AddrModeFlat;
        for (int d = 0; d < 40; d++) {
          if (!StackWalk64(IMAGE_FILE_MACHINE_AMD64, proc, th, &f, &c, NULL, SymFunctionTableAccess64, SymGetModuleBase64, NULL)) break;
          if (!f.AddrPC.Offset) break;
          where(o, f.AddrPC.Offset);
        }
      }
      fflush(o);
      break; }
    case EXIT_PROCESS_DEBUG_EVENT:
      exit_code = ev.u.ExitProcess.dwExitCode;
      ContinueDebugEvent(ev.dwProcessId, ev.dwThreadId, DBG_CONTINUE);
      fprintf(o, "exit %lx\n", exit_code); fclose(o);
      printf("exit %lx, %d access violations\n", exit_code, av);
      return 0;
    }
    ContinueDebugEvent(ev.dwProcessId, ev.dwThreadId, cont);
  }
  return 1;
}
