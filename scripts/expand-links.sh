#!/bin/bash
if [ -f "/tmp/workspace/links.txt" ]
then
    cat /tmp/workspace/links.txt | while read line
    do
	echo "expand: $line"
    done
fi
