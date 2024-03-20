#!/bin/bash

# Peforms a parse of all topics from repos.md and outputs to topics.md file for reference by repos.md Topics link.
# This script executes as part of the Git pre-commit hook.

date=$(date +%m/%d/%Y)

scriptpath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
#echo $scriptpath

if [ ! -f $scriptpath/topics.md ]
then
    touch $scriptpath/topics.md
fi

rm $scriptpath/topics.md

cat << EOF > $scriptpath/topics.md
---
layout: page
title: GitHub Topics
permalink: /topics/
---

A list of searchable topics parsed across all repos

EOF

cat $scriptpath/repos.md | grep -o -P '(?<=topic%3A).*?(?=\&)' | sed 's/+topic%3A/\n/g' | sort -u | awk '{print "* " $0}' >> $scriptpath/topics.md
echo '' >> $scriptpath/topics.md
echo "<sub>Last automated update: $date<sub>" >> $scriptpath/topics.md
