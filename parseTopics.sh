#!/bin/bash

rm topics.md

cat << EOF > topics.md
---
layout: page
title: GitHub Topics
permalink: /topics/
---

EOF

cat repos.md | grep -o -P '(?<=topic%3A).*?(?=\&)' | sed 's/+topic%3A/\n/g' | sort -u | awk '{print "* " $0}' >> topics.md
