"""Break down the excluded W3C cases by reason, recommendation, version, edition and type."""
import importlib.util
import sys
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

runner_path, suite_dir = Path(sys.argv[1]), Path(sys.argv[2])
spec = importlib.util.spec_from_file_location("runner", runner_path)
runner = importlib.util.module_from_spec(spec)
sys.modules["runner"] = runner
spec.loader.exec_module(runner)

cases = runner.load_catalog(suite_dir)
print("total", len(cases))
excluded = [c for c in cases if c.skip_reason]
print("excluded", len(excluded))
print(Counter(c.skip_reason for c in excluded).most_common())

# Re-read raw attributes for the excluded cases.
attrs = {}
for path in [suite_dir / "xmlconf.xml"]:
    pass
raw = {}


def collect(element):
    if element.tag == "TEST":
        raw[element.get("ID")] = dict(element.attrib)
    for child in element:
        collect(child)


# load_catalog expands entities internally; rebuild the same tree through its parser pieces
import pyexpat as expat
builder = ET.TreeBuilder()
root = suite_dir.resolve()


def configure(parser, path):
    parser.SetBase(path.as_uri())
    parser.StartElementHandler = builder.start
    parser.EndElementHandler = builder.end
    parser.CharacterDataHandler = builder.data
    parser.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)

    def external(context, base, system_id, public_id):
        target = runner.local_uri(root, base, system_id)
        child = parser.ExternalEntityParserCreate(context)
        configure(child, target)
        child.Parse(target.read_bytes(), True)
        return 1
    parser.ExternalEntityRefHandler = external


data = (root / "xmlconf.xml").read_bytes()
parser = expat.ParserCreate("ISO-8859-1")
configure(parser, root / "xmlconf.xml")
parser.Parse(data, True)
collect(builder.close())

groups = Counter()
for c in excluded:
    a = raw[c.id]
    groups[(c.skip_reason.split(" is ")[0].split(" has ")[0][:40], a.get("RECOMMENDATION", "XML1.0"),
            a.get("VERSION", "-"), a.get("EDITION", "-"), a["TYPE"], a.get("ENTITIES", "none") != "none")] += 1
print()
print("reason | recommendation | VERSION | EDITION | TYPE | entities | count")
for key, n in sorted(groups.items()):
    print(" | ".join(map(str, key)), "|", n)

# Which edition-excluded cases have a 5th-edition twin?
print()
ed = [c for c in excluded if "fifth edition" in c.skip_reason]
print("edition-excluded:", len(ed), Counter(raw[c.id].get("EDITION") for c in ed))
print("by TYPE:", Counter(raw[c.id]["TYPE"] for c in ed))
print("by dir:", Counter(str(c.path.relative_to(root)).split("\\")[0] + "/" + str(c.path.relative_to(root)).split("\\")[1] for c in ed).most_common(10))
v11 = [c for c in excluded if "1.1" in c.skip_reason or "XML 1.0" in c.skip_reason]
print("1.1 / not-1.0:", len(v11), Counter((raw[c.id].get("RECOMMENDATION"), raw[c.id].get("VERSION", "-")) for c in v11))
print("1.1 TYPE:", Counter(raw[c.id]["TYPE"] for c in v11))
opt = [c for c in excluded if "Optional" in c.skip_reason]
print("optional:", len(opt), Counter(raw[c.id].get("RECOMMENDATION") for c in opt))
for c in opt:
    print("  ", c.id, raw[c.id].get("RECOMMENDATION"), raw[c.id].get("ENTITIES"), "|", c.description[:110])
