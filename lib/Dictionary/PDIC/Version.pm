package Dictionary::PDIC::Version;

use strict;

#require Exporter;
#use vars qw(@ISA @EXPORT);
#@ISA = qw(Exporter);
#@EXPORT = qw(version_bcd);

use Dictionary::Util::Binary; # bcd_to_dec

sub version_bcd {
    my $pdicfile = shift;

    my $buf;
    open FH, '<', $pdicfile;
    seek FH, 140, 0;
    read FH, $buf, 2;
    close FH;

    unpack("v", $buf);
}

sub version {
    my $pdicfile = shift;
    my $version_in_bcd = &version_bcd($pdicfile);

    bcd_to_dec($version_in_bcd) / 100;
}
sub major_version {
    my $pdicfile = shift;
    my $version_in_bcd = &version_bcd($pdicfile);

    $version_in_bcd >> 8;
}
sub minor_version {
    my $pdicfile = shift;
    my $version_in_bcd = &version_bcd($pdicfile);

    $version_in_bcd & 0xff;
}

1;
