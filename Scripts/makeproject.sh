#!/usr/bin/env bash

dest=$1
name=$2

mkdir -p "$dest/$name"
cp -R . "$dest/$name/"
perl -p -i -e "s/{{name}}/$name/g" "$dest/$name/"*
#grep -lr -e '{{name}}' "$dest/$name" | xargs sed -i "'s/{{name}}/$name/g'"
open "$dest/$name"