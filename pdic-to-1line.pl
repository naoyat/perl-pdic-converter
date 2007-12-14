#!/usr/bin/env perl
#
# PDIC --> PDIC 1-Line text
#
use strict;
use lib qw(./lib);

use Dictionary::PDIC;

use Encode;
use Encode::Guess;
use Encode::BOCU1;


my $pdicfile = $ARGV[0];
my $pdic = new Dictionary::PDIC $pdicfile;

my $encoding = ($#ARGV >= 1)? $ARGV[1] : 'utf8';

$pdic->dump($encoding, 'PDIC-1LINE');

1;

