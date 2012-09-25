#!/bin/sh

./build.sh

if [ "$?" = 0 ] ; then
  ./main "$@"
fi