# Best of 3 per input: bash timing.sh <xpact_benchmarks.exe> <inputs folder from make_inputs.py> <xmlconf folder>
W="$2"; J="$3/japanese"
for f in $W/tiny.xml $W/plain8.xml $W/r500_100k.xml $W/r500_400k.xml $W/r2000_100k.xml $W/r2000_400k.xml $W/r2000_400k_amp.xml $J/pr-xml-utf-8.xml $J/pr-xml-utf-16.xml; do
  best=999999; v=""
  for r in 1 2 3; do s=$(date +%s%N); v=$("$1" --conformance-file "$f" | head -1 | cut -f2); d=$(( ($(date +%s%N)-s)/1000000 )); [ $d -lt $best ] && best=$d; done
  printf "%-20s %8s bytes  %-6s %6s ms\n" "$(basename $f)" "$(wc -c < "$f")" "$v" "$best"
done
