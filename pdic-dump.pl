#
# pdic-dump.pl 
#
# by naochan <pdicviewer@naochan.com>
#
use strict;
use lib qw(./lib);

use Dictionary::PDIC;

my $pdicfile = $ARGV[0];
my $pdic = new Dictionary::PDIC $pdicfile;

$pdic->dump('sjis', 'PDIC-1LINE');

1;

