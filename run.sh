#!/bin/bash

make clean
make > make.ou
cat make.ou
cat tmp_build_dir/d/1d.gnu.DEBUG.MPI.exe/f90.depends
make help
make print-F90EXE_sources
make file_locations
