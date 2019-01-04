#!/bin/bash
for i in `cat smk.csv  | awk -F, '{print $1}'`; do ssh $i -p22; done
