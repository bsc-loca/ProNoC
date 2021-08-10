#!/bin/bash
	SCRPT_FULL_PATH=$(realpath ${BASH_SOURCE[0]})
	SCRPT_DIR_PATH=$(dirname $SCRPT_FULL_PATH)

echo "\$SCRPT_DIR_PATH is $SCRPT_DIR_PATH"

export PRONOC_WORK=$SCRPT_DIR_PATH/../../mpsoc_work
export PATH=$PATH:/opt/verilator/bin
source "/eda/env.sh"

home=$(eval echo ~$USER)
echo "source $home/perl5/perl_env.sh"

source "$home/perl5/perl_env.sh"

./verify.perl "20"



