#!/bin/bash

BASE=`dirname $0`/..
BENCH_RESULTS="$BASE/benchresults"

grep -A1 '^compression' "$BENCH_RESULTS/benches.txt" | grep -v change | sed '/^compression.*pack.*$/{N;s/\n/ /}' | grep -v '^--$' | awk '{print $1","$5" "$6}' | tee "$BENCH_RESULTS/benches.csv"

(
echo "bench,time,ns"
while read L
do
	V=`echo $L | cut -f2 -d, | sed 's/ ns$//;s/ us$/\*1000/;s/ ms$/*1000000/;s/ s$/*1000000000/' | bc -l`
	echo "$L,$V"
done <"$BENCH_RESULTS/benches.csv" | sort -t, -nk3
) | tee "$BENCH_RESULTS/benches-2.csv"
mv "$BENCH_RESULTS/benches-2.csv" "$BENCH_RESULTS/benches.csv"

egrep '(^bench,|\.unpack)' "$BENCH_RESULTS/benches.csv" >"$BENCH_RESULTS/benches-unpack.csv"
egrep '(^bench,|\.pack)' "$BENCH_RESULTS/benches.csv" >"$BENCH_RESULTS/benches-pack.csv"
