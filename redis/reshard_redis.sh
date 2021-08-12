for i in `seq 13656 16383`; do
    redis-cli -c -p 7000 cluster setslot ${i} importing 806b4104430acae7e3fdd0b8dd40cb337f6660ea
    redis-cli -c -p 7002 cluster setslot ${i} migrating db6c36416e775803866749efa78f5d663f819b61
    while true; do
        key=`redis-cli -c -p 7002 cluster getkeysinslot ${i} 1`
        if [ "" = "$key" ]; then
            echo "there are no key in this slot ${i}"
            break
        fi
        redis-cli -p 7002 migrate 127.0.0.1 7000 ${key} 0 5000
    done
    redis-cli -c -p 7002 cluster setslot ${i} node db6c36416e775803866749efa78f5d663f819b61
    redis-cli -c -p 7001 cluster setslot ${i} node db6c36416e775803866749efa78f5d663f819b61
    redis-cli -c -p 7000 cluster setslot ${i} node db6c36416e775803866749efa78f5d663f819b61
done
