#!/bin/bash

#example: ./first-script.sh '1 2 3 4 5' ./dir

SUM=0

for number in $1; do
  if ((number % 2 == 0)); then
    SUM=$(($SUM + $number))
  fi
done

echo 'sum:' $SUM


DIR=$2
if [ -z $DIR ] || [ ! -d $DIR ]; then
  DIR='.'
fi

echo "clone example from github? y/n"

read IS_NEED_CLONE

if [ $IS_NEED_CLONE == 'y' ]; then
  git clone https://github.com/StartBootstrap/startbootstrap-sb-admin-2.git $DIR/example
fi

for file in $(find $DIR -name '*.css') $(find $DIR -name '*.js'); do
  tar -c -z -v -f $file.tar.gz $file
done