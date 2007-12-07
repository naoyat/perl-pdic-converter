package Dictionary::Util::LittleEndian;

use strict;

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(get_uchar_value get_char_value get_ushort_value get_short_value get_ulong_value get_long_value get_unsigned_value get_cstring);

sub get_uchar_value {
    my ($buf,$ofs) = @_;
    unpack("C", substr($buf,$ofs));
}
sub get_char_value {
    my ($buf,$ofs) = @_;
    unpack("c", substr($buf,$ofs));
}
sub get_ushort_value {
    my ($buf,$ofs) = @_;
    my $value = unpack("v", substr($buf,$ofs));
#    my ($lower,$higher) = unpack("CC", substr($buf,$ofs));
#    my $value = ($higher << 8) | $lower;
    $value;
}
sub get_short_value {
    my $value = get_ushort_value(@_);
    return ($value >= 32768) ? ($value - 65536) : $value;
}
sub get_ulong_value {
    my ($buf,$ofs) = @_;
    my $value = unpack("V", substr($buf,$ofs));
#    my ($lowest,$lower,$higher,$highest) = unpack("CCCC", substr($buf,$ofs));
#    my $value = ($highest << 24) | ($higher << 16) | ($lower << 8) | $lowest;
    $value;
}
sub get_long_value {
    my $value = get_ulong_value(@_);
    return ($value >= 2147483648) ? ($value - 4294967296) : $value;
}

sub get_unsigned_value {
    my ($buf,$ofs,$bytes) = @_;
    if ($bytes == 4) {
        return get_ulong_value($buf,$ofs);
    } elsif ($bytes == 2) {
        return get_ushort_value($buf,$ofs);
    } elsif ($bytes == 1) {
        return get_uchar_value($buf,$ofs);
    } else {
        return undef;
    }
}
sub get_signed_value {
    my ($buf,$ofs,$bytes) = @_;
    if ($bytes == 4) {
        return get_long_value($buf,$ofs);
    } elsif ($bytes == 2) {
        return get_short_value($buf,$ofs);
    } elsif ($bytes == 1) {
        return get_char_value($buf,$ofs);
    } else {
        return undef;
    }
}

sub get_cstring {
    my ($buf,$ofs) = @_;
    return unpack("Z*", substr($buf,$ofs));
}

##

1;
