#!/bin/bash
#Name: build.sh
#Purpose: Compile tater into binaries
#Author: Freddie Rosario <rosario@ecohealthalliance.org>

rm -fr build/
meteor build build --directory --architecture os.linux.x86_64
