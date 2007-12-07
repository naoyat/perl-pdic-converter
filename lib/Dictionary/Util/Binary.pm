package Dictionary::Util::Binary;

use strict;

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(bcd_to_dec is_little_endian is_big_endian);

#use Dictionary::Util::LittleEndian;

#
#
#
sub bcd_to_dec {
    my ($bcd_value) = @_;
    my $dec_value = 0;
    my $shift = 1;

    my $tmp = $bcd_value;
    while ($tmp != 0) {
        my $digit = $tmp & 0xf;
        die sprintf("invalid BCD digit (%x) in 0x%x", $digit, $bcd_value) if $digit >= 10;
        $dec_value += $digit * $shift;
        $tmp >>= 4;
        $shift *= 10;
    }
    $dec_value;
}

sub is_little_endian {
    (unpack("S","AB") == 0x4241) ? 1 : 0;
}
sub is_big_endian {
    (unpack("S","AB") == 0x4142) ? 1 : 0;
}

1;
