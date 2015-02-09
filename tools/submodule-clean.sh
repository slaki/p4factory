#!/bin/sh

git submodule update

for sub in $(git submodule | cut -d' ' -f3); do
    ( cd $sub; git clean -fx )
done
