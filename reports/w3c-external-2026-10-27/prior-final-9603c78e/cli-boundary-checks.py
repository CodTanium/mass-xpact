from pathlib import Path
import sys,json,subprocess,uuid,datetime,hashlib,os
repo=Path.cwd()
base=repo/'build/local-resolver-cli-checks'/(datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ-')+uuid.uuid4().hex[:12]);base.mkdir(parents=True)
# Usage: python build/check_local_resolver_cli.py LABEL=EXE [LABEL=EXE ...]
report={'campaign':str(base),'engines':[]}
for value in sys.argv[1:]:
 label,path=value.split('=',1);exe=Path(path).resolve();engine=base/label;engine.mkdir();results=[]
 def check(name,document=b'<root/>',resources=None,expected=0,marker='ACCEPT',identifier=None,extra=None):
  work=engine/name;root=work/'suite';root.mkdir(parents=True);(root/'document.xml').write_bytes(document)
  for relative,content in (resources or {}).items():
   dest=root/relative;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(content)
  command=[str(exe),'--conformance-file',str(root/'document.xml'),'--suite-root',str(root)]+(extra or [])
  if identifier=='outside_primary':
   outside=work/'outside.xml';outside.write_bytes(b'<root/>');command[2]=str(outside)
  elif identifier=='missing_root':command[4]=str(work/'missing-root')
  elif identifier=='missing_primary':command[2]=str(root/'missing.xml')
  elif identifier=='junction':
   shared=Path(os.environ['XPACT_JUNCTION_FIXTURE'])
   assert (shared/'suite/link').is_dir()
   command[2]=str(shared/'suite/document.xml');command[4]=str(shared/'suite')
  completed=subprocess.run(command,cwd=work,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=10)
  stdout=completed.stdout.decode('utf-8',errors='replace');stderr=completed.stderr.decode('utf-8',errors='replace')
  wanted=[] if marker is None else ['XPACT_CONFORMANCE\t'+marker]
  found=[line for line in stdout.splitlines() if line.startswith('XPACT_CONFORMANCE\t')]
  ok=completed.returncode==expected and found==wanted
  result={'case':name,'passed':ok,'expected_exit':expected,'expected_marker':marker,'exit_code':completed.returncode,'stdout':stdout,'stderr':stderr,'command':command}
  results.append(result);(work/'result.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
 def xml(reference):return ("<!DOCTYPE root [<!ENTITY ext SYSTEM '"+reference+"'>]><root>&ext;</root>").encode()
 check('local_external_markup',xml('entity.ent'),{'entity.ent':b'<leaf>content</leaf>'})
 check('empty_external_file',xml('empty.ent'),{'empty.ent':b''})
 check('raw_utf16_external',xml('utf16.ent'),{'utf16.ent':b'\xff\xfe'+'<leaf>value</leaf>'.encode('utf-16le')})
 check('percent_encoded_name',xml('space%20file.ent'),{'space file.ent':b'<leaf/>'})
 check('declaring_resource_base',b"<!DOCTYPE root SYSTEM 'sub/root.dtd'><root>&ext;</root>",{'sub/root.dtd':b"<!ENTITY ext SYSTEM 'entity.ent'>",'sub/entity.ent':b'<leaf/>','entity.ent':b'<broken'})
 check('missing_external_file',xml('absent.ent'),expected=2,marker=None)
 check('missing_external_subset',b"<!DOCTYPE root SYSTEM 'absent.dtd'><root/>",expected=2,marker=None)
 check('path_escape',xml('../outside.ent'),expected=2,marker=None)
 check('percent_path_escape',xml('%2e%2e%2foutside.ent'),expected=2,marker=None)
 check('network_resource',xml('https://example.invalid/entity'),expected=2,marker=None)
 check('file_uri',xml('file:///outside.ent'),expected=2,marker=None)
 check('zero_identifier',xml('bad%00.ent'),expected=2,marker=None)
 check('win32_parent_alias',xml('.. /outside.ent'),expected=2,marker=None)
 check('win32_device_name',xml('nul.txt'),expected=2,marker=None)
 check('junction_resource',xml('link/entity.ent'),expected=2,marker=None,identifier='junction')
 check('attribute_rejected_before_missing_resource',b"<!DOCTYPE root [<!ENTITY ext SYSTEM 'absent.ent'>]><root a='&ext;'/>",expected=1,marker='REJECT')
 check('attlist_default_rejected_before_missing_resource',b"<!DOCTYPE root [<!ENTITY ext SYSTEM 'absent.ent'><!ATTLIST root a CDATA '&ext;'>]><root/>",expected=1,marker='REJECT')
 check('standalone_external_declaration_before_missing_resource',b"<?xml version='1.0' standalone='yes'?><!DOCTYPE root SYSTEM 'root.dtd'><root>&ext;</root>",{'root.dtd':b"<!ENTITY ext SYSTEM 'absent.ent'>"},expected=1,marker='REJECT')
 check('notation_and_unparsed_ids_not_loaded',b"<!DOCTYPE root [<!NOTATION image SYSTEM 'https://example.invalid/metadata'><!ENTITY logo SYSTEM 'file:///missing.bin' NDATA image>]><root/>")
 check('outside_primary',identifier='outside_primary',expected=2,marker=None)
 check('missing_primary',identifier='missing_primary',expected=2,marker=None)
 check('missing_root',identifier='missing_root',expected=2,marker=None)
 check('duplicate_suite_root',extra=['--suite-root',str(engine/'irrelevant')],expected=2,marker=None)
 check('unknown_option',extra=['--unexpected'],expected=2,marker=None)
 print(label+': '+str(sum(r['passed'] for r in results))+'/'+str(len(results))+' fixtures',flush=True)
 report['engines'].append({'label':label,'executable':str(exe),'executable_sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'results':results})
(base/'report.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
(repo/'build/local-resolver-cli-latest.txt').write_text(str(base))
if not all(row['passed'] for engine in report['engines'] for row in engine['results']):raise SystemExit(1)
