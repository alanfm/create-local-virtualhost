#!/bin/bash

service="default"
node="default"

while getopts 's:n:' opt; do
    case $opt in
        s)  service="$OPTARG" ;;
        n)  node="$OPTARG"    ;;
        *)  exit 1            ;;
    esac
done

echo "service = '${service}'"
echo "node    = '${node}'"