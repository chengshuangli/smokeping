#!/bin/bash

for i in `cat smk.csv`
    do
        echo $i
        ip=$(echo $i | awk -F, '{print $1}')
        name=$(echo $i | awk -F, '{print $2}')-$ip
        file=$(echo $i | awk -F, '{print $2}' | awk -F'-' '{print $1}')
        [ -d guilei ] || mkdir guilei
        [ -d guilei/$file ] || mkdir guilei/$file
        cp once/*$ip* guilei/$file/$name.csv
    done
