#!/bin/bash

rev=$1

if [ $# -eq 0 ]
    then
    rev=$(git rev-parse --abbrev-ref HEAD)    
fi

remote=$(git config --get remote.origin.url)
remote=${remote/git@/}
remote=${remote/:/\/}
remote=${remote/.git/\/}

parent=`cat VERSION`

remote=https://${remote}compare/${parent}...${rev}?expand=1
echo $remote
open $remote