#!/bin/sh
#
# convert-all (for Eijiro Viewer)
#
DICT_DIR=~/Desktop/PDICViewer1024EE/Dictionaries

mkdir -p converted
for f in $DICT_DIR/*.DIC ; do
  name=`basename $f | perl -pe 's/\.DIC$//; tr/A-Z/a-z/'`
  echo "[$name]"
  perl ./pdic-to-1line.pl $f sjis | LC_ALL='C' sort -f | sed -f ./eview.sed > converted/$name.eview.txt
done

