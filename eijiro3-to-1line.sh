#!/bin/sh
#
# convert-all (into PDIC 1-line)
#
DICT_DIR=~/Desktop/PDICViewer1024EE/Dictionaries

mkdir -p converted
for f in $DICT_DIR/*.DIC ; do
  name=`basename $f | perl -pe 's/\.DIC$//; tr/A-Z/a-z/'`
  echo "[$name]"
  perl ./pdic-to-1line.pl $f sjis > converted/$name.1line.txt
done

