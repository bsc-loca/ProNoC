#!/bin/bash

top="noc_top"


echo "filelist: $1";
export workspace_loc="$1/../.."
verilator --lint-only  --cc  --top-module $top   --profile-cfuncs --prefix "Vnoc" -O3  -CFLAGS -O3 -f $1/filelist.f -y ${workspace_loc}/mpsoc/src_noc/
