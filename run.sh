#!/usr/bin/env bash

make clean
make DEP_CHECK_OPTS=--debug > make.ou
ls .
cat make.ou
cat dependencies.out
cat tmp_build_dir/d/1d.gnu.DEBUG.MPI.exe/f90.depends
make help
make print-F90EXE_sources
make file_locations
