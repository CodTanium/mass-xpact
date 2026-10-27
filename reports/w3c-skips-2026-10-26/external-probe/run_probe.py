from pathlib import Path
import sys, json, subprocess, time, collections, hashlib, argparse, uuid
from datetime import datetime, timezone
repo=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(repo/'scripts'))
import run_w3c_conformance as w3c
arguments=argparse.ArgumentParser()
arguments.add_argument('--executable',type=Path,required=True)
arguments.add_argument('--output-dir',type=Path,help='New report directory; must not already exist')
args=arguments.parse_args()
probe=args.output_dir.resolve() if args.output_dir else repo/'build/w3c-skip-investigation/external-probe-runs'/(datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ-')+uuid.uuid4().hex[:12])
probe.mkdir(parents=True,exist_ok=False)
print('Diagnostic probe results: '+str(probe),flush=True)
exe=args.executable.resolve()
suite=(repo/'build/validation-corpora/w3c-xml-20130923/xmlconf').resolve()
cases=[c for c in w3c.load_catalog(repo/'build/validation-corpora/w3c-xml-20130923/xmlconf') if c.skip_reason.startswith('Requires external ')]
results=[]
for index,c in enumerate(cases,1):
    work=probe/'work-final'/c.id.replace('/','_').replace('\\','_').replace(':','_')
    work.mkdir(parents=True,exist_ok=True)
    command=[str(exe),str(c.path),str(suite)]+(['--namespaces'] if c.namespaces else [])
    start=time.perf_counter()
    try:
        p=subprocess.run(command,cwd=work,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=10)
        stdout,stderr=p.stdout,p.stderr
        lines=stdout.decode('utf-8',errors='replace').splitlines()
        verdicts=[line.split('\t')[-1] for line in lines if line.startswith('XPACT_CONFORMANCE\t')]
        actual=verdicts[0] if len(verdicts)==1 else 'abnormal'
        status=('passed' if actual==c.expected else 'failed') if actual in ('ACCEPT','REJECT') and p.returncode==(0 if actual=='ACCEPT' else 1) else 'error'
        rc=p.returncode
    except subprocess.TimeoutExpired as ex:
        stdout,stderr=ex.stdout or b'',ex.stderr or b''
        actual,status,rc='timeout','error',None
    (work/'stdout.txt').write_bytes(stdout)
    (work/'stderr.txt').write_bytes(stderr)
    limitation=any(marker in stderr for marker in (b'PROBE_RESOLVER_UNSUPPORTED_PATH',b'PROBE_RESOLVER_MISSING_FILE'))
    result=dict(case_id=c.id,path=c.path.relative_to(suite).as_posix(),kind=c.kind,namespaces=c.namespaces,expected=c.expected,actual=actual,status=status,returncode=rc,elapsed_seconds=time.perf_counter()-start,resolver_limitation=limitation,resolve_calls=stderr.count(b'RESOLVE\t'),stdout=stdout.decode('utf-8',errors='replace'),diagnostic=stderr.decode('utf-8',errors='replace'))
    result['conformance_assessment']='inconclusive' if limitation or c.id in {'not-wf-sa-081','not-wf-sa-082','rmt-e2e-18'} else status
    result['process_arguments']=['<executable>','<suite>/'+c.path.relative_to(suite).as_posix(),'<suite>']+(['--namespaces'] if c.namespaces else [])
    if c.id in {'not-wf-sa-081','not-wf-sa-082'}:
        result['limitation']='Reserved/nonexistent nul resource denied; matching REJECT is not proof that the document defect was detected.'
    elif c.id=='rmt-e2e-18':
        result['limitation']='Probe resolves nested external identifiers from the top document directory rather than declaration location.'
    results.append(result)
    (work/'result.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
    if index%50==0: print(f'{index}/{len(cases)}',flush=True)
summary=dict(total=len(results),counts=dict(collections.Counter(r['status'] for r in results)),verdicts=dict(collections.Counter((r['expected']+'->'+r['actual']) for r in results)),resolver_limitations=sum(r['resolver_limitation'] for r in results),with_resolve_calls=sum(r['resolve_calls']>0 for r in results),executable_sha256=hashlib.sha256(exe.read_bytes()).hexdigest(),profile='XP_PARSER assertions retained; All_external_entities; raw suite bytes; diagnostic suite-contained loader; nested identifiers still relative to top document; no production edits',assessments=dict(collections.Counter(r['conformance_assessment'] for r in results)),results=results)
(probe/'results.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in summary.items() if k!='results'},indent=2))
