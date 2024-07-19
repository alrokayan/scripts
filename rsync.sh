#!/bin/bash
# $1 From
# $2 To
rsync -avzrlt --progress $1 $2
