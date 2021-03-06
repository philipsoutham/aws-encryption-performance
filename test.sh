#!/bin/env bash

for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19; do
    ####################### SSE ###############################
    echo "doing sse $i"
    sar -p 1 > "async_yes_ssl_yes_sse-cpu.${i}.sar.txt" &
    sar_cpu=$!

    sar -p -n DEV 1 > "async_yes_ssl_yes_sse-network.${i}.sar.txt" &
    sar_network=$!

    sleep 1
    
    jobs=""
    for j in 0 1 2 3 4 5 6 7; do
	~/aws s3 cp /media/ramfs/data/data.30g "s3://psoutham-encryption-test/output/${j}_yes_sse_async_${i}.30g"  --storage-class REDUCED_REDUNDANCY --endpoint-url https://s3-us-west-2.amazonaws.com --sse "aws:kms" --sse-kms-key-id a9de2efa-8278-420c-86ea-272881fcde8d &
	jobs="${jobs} $!"
	usleep 300000 
    done
    echo "waiting for ${jobs}"
    wait ${jobs}
    sleep 1
    kill "${sar_cpu}" "${sar_network}"

    ####################### SSL ###############################

    echo "doing ssl $i"
    sar -p 1 > "async_yes_ssl_no_sse-cpu.${i}.sar.txt" &
    sar_cpu=$!

    sar -p -n DEV 1 > "async_yes_ssl_no_sse-network.${i}.sar.txt" &
    sar_network=$!

    sleep 1
    
    jobs=""
    for j in 0 1 2 3 4 5 6 7; do
	~/aws s3 cp /media/ramfs/data/data.30g "s3://psoutham-encryption-test/output/${j}_yes_ssl_async_${i}.30g"  --storage-class REDUCED_REDUNDANCY --endpoint-url https://s3-us-west-2.amazonaws.com  &
	jobs="${jobs} $!"
	usleep 300000 
    done
    echo "waiting for ${jobs}"
    wait ${jobs}
    sleep 1
    kill "${sar_cpu}" "${sar_network}"

    ####################### PLAINTEXT ###############################

    echo "doing plaintext $i"
    sar -p 1 > "async_no_ssl_no_sse-cpu.${i}.sar.txt" &
    sar_cpu=$!

    sar -p -n DEV 1 > "async_no_ssl_no_sse-network.${i}.sar.txt" &
    sar_network=$!

    sleep 1
    
    jobs=""
    for j in 0 1 2 3 4 5 6 7; do
	~/aws s3 cp /media/ramfs/data/data.30g "s3://psoutham-encryption-test/output/${j}_no_ssl_async_${i}.30g"  --storage-class REDUCED_REDUNDANCY --endpoint-url http://s3-us-west-2.amazonaws.com &
	jobs="${jobs} $!"
	usleep 300000 
    done
    echo "waiting for ${jobs}"
    wait ${jobs}
    sleep 1
    kill "${sar_cpu}" "${sar_network}"
done
