#!/bin/bash
# set -x
if [ $# -lt 3 ]; then
    echo "usage: $0 num_servers num_workers bin [args..]"
    exit -1;
fi

export DMLC_NUM_SERVER=$1
shift
export DMLC_NUM_WORKER=$1
shift
bin=$1
shift
arg="$@"

# start the scheduler
#export DMLC_PS_ROOT_URI='127.0.0.1'
export DMLC_ENABLE_RDMA=1
export DMLC_PS_VAN_TYPE=ibverbs
export DMLC_INTERFACE=eno1        # my RDMA interface
export DMLC_PS_ROOT_URI='172.29.2.41'  # scheduler's RDMA interface IP  <- get both of these out of my lapse setup-tool
export DMLC_PS_ROOT_PORT=8000
export DMLC_ROLE='scheduler'
${bin} ${arg} &


# start servers
export DMLC_ROLE='server'
for ((i=0; i<${DMLC_NUM_SERVER}; ++i)); do
    export HEAPPROFILE=./S${i}
    ${bin} ${arg} &
done

# start workers
export DMLC_ROLE='worker'
for ((i=0; i<${DMLC_NUM_WORKER}; ++i)); do
    export HEAPPROFILE=./W${i}
    ${bin} ${arg} &
done

wait
