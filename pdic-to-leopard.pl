#!/usr/bin/env perl
#
# PDIC --> Leopard's dictionary
#
# This script is written by naoya_t, on 13-14 Dec 2007.
# シェルスクリプトっぽくてごめん
#
use strict;
use lib qw(./lib);

use Dictionary::PDIC;

use Encode;
use Encode::Guess;
use Encode::BOCU1;

use File::Basename;

#
# usage
#
if ($#ARGV == -1) {
	print "usage: pdic-to-leopard pdicfile [fontfamily]\n";
	exit;
}

my $template_dir = "/Developer/Extras/Dictionary Development Kit/project_templates";
unless (-e $template_dir) {
	print "Not found: $template_dir\n";
	exit;
}

my $pdicfile = $ARGV[0];
unless (-e $pdicfile) {
	print "Not found: $pdicfile\n";
	exit;
}

my $fontfamily = ($#ARGV >= 1)? $ARGV[1] : "";

my $pdic = new Dictionary::PDIC $pdicfile;
if ($pdic->version < 4) {
	print "Unsupported format: $pdicfile\n";
	exit;
}

my $name = basename($pdicfile, (".dic",".DIC"));

print "$pdicfile => ~/Library/Dictionaries/$name.dictionary ... ";
mkdir($name);

# /Developer/Examples/Dictionary Development Kit/project_templates/
system("rm -rf $name/project_templates");
system("cp -R '$template_dir' $name/");
# system("tar zxf project_templates.tar.gz -C $name/");


open(my $xml,"> $name/project_templates/MyDictionary.xml");
print $xml <<"EOF";
<?xml version="1.0" encoding="UTF-8"?>
<d:dictionary xmlns="http://www.w3.org/1999/xhtml" xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng">
EOF

$pdic->dump_fh($xml, "utf8", "Leopard");

print $xml "</d:dictionary>\n";
close($xml);

if ($fontfamily) {
	open(CSS, ">> $name/project_templates/MyDictionary.css");
	print CSS <<"EOF";

span.headword {
	font-family: $fontfamily;
}
EOF
	close(CSS);
}

chdir("$name/project_templates");

system("sed -i .orig 's/My Dictionary/$name/g' Makefile");
system("sed -i .orig 's/>MyDictionary</>$name</g; s/MySample/$name/g; s/Apple Inc./PDIC-Converter/g' MyInfo.plist");

my $logfile = "convert.log";
system("make > $logfile");
system("make install >> $logfile");
chdir("../..");

print "done!\n";
1;
