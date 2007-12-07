#!/bin/sh
#
# convert-all (into PDIC 1-line)
#
DICT_DIR=~/Desktop/PDICViewer1024EE/Dictionaries

for f in $DICT_DIR/*.DIC ; do
  name=`basename $f | perl -pe 's/\.DIC$//; tr/A-Z/a-z/'`
  echo "[$name]"
  perl ./pdic-dump.pl $f > $name.txt
done

