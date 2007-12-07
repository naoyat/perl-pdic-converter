#!/bin/sh
#
# convert-all (for Eijiro Viewer)
#
DICT_DIR=~/Desktop/PDICViewer1024EE/Dictionaries

for f in $DICT_DIR/*.DIC ; do
  name=`basename $f | perl -pe 's/\.DIC$//; tr/A-Z/a-z/'`
  echo "[$name]"
  perl ./pdic-dump.pl $f | sort -f | sed -f ./eview.sed > $name.txt
done

