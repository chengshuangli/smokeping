#!/bin/bash


for i in `cat smk.csv`
    do
        ip=$(echo $i | awk -F, '{print $1}')
        name=$(echo $i | awk -F, '{print $2}')
    echo $name,  http://$ip/htdocs/smokeping.cgi
done

