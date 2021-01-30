#!/bin/bash

BASE=`dirname $0`/..
BENCH_RESULTS="$BASE/benchresults"

# Filter/organize fields: bench,time,size
egrep '(^compression\b|\btime:|\bbytes\b|^Benchmarking\b)' "$BENCH_RESULTS/benches.txt" | grep -v '^uncompressed:' | sed 's/^Benchmarking\b.*//' | sed '/^compression\b/{N;N;s/\n/ /g}' | grep -v '^$' | awk '{print $1","$5" "$6","$10}' >"$BENCH_RESULTS/benches.csv"

# Uncompressed file size
USZ=`grep '^uncompressed:' "$BENCH_RESULTS/benches.txt" | cut -d\  -f2`

(
echo "bench,time,size,compression_ratio,ns"
while read L
do
	# Compute nanoseconds
	NS=`echo $L | cut -f2 -d, | sed 's/ ns$//;s/ us$/\*1000/;s/ ms$/*1000000/;s/ s$/*1000000000/' | bc -l`

  # Compute compression ratio
	C=NA
	SZ=`echo $L | cut -f3 -d,`
	[ -n "$SZ" ] && C=`echo -e "scale=3\n$SZ/$USZ" | bc -l`

	echo "$L,$C,$NS"
done <"$BENCH_RESULTS/benches.csv" | sort -t, -gk5
) | tee "$BENCH_RESULTS/benches-2.csv"
mv "$BENCH_RESULTS/benches-2.csv" "$BENCH_RESULTS/benches.csv"

egrep '(^bench,|\.unpack)' "$BENCH_RESULTS/benches.csv" >"$BENCH_RESULTS/benches-unpack.csv"
egrep '(^bench,|\.pack)' "$BENCH_RESULTS/benches.csv" >"$BENCH_RESULTS/benches-pack.csv"
