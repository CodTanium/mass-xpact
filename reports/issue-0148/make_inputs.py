"""Write the timing inputs of reports/issue-0148 into a folder: python make_inputs.py <folder>"""
import sys
from pathlib import Path

out = Path(sys.argv[1])
out.mkdir(parents=True, exist_ok=True)
(out / "tiny.xml").write_bytes(b"<a/>")
(out / "plain8.xml").write_bytes(b"<doc>" + b"<p a='1'>hello world, some text here</p>\n" * 40000 + b"</doc>")
declaration = b'<!DOCTYPE doc [<!ENTITY e "x">]>'
for references in (500, 2000):
    for kilobytes in (100, 400):
        filler = b"<p>hello world, some text here</p>\n" * (kilobytes * 1024 // 36)
        (out / f"r{references}_{kilobytes}k.xml").write_bytes(
            declaration + b"<doc>" + filler + b"<p>&e;</p>\n" * references + b"</doc>")
        (out / f"r{references}_{kilobytes}k_amp.xml").write_bytes(
            b"<doc>" + filler + b"<p>&amp;</p>\n" * references + b"</doc>")
