package PDIC::Record;

use strict;

sub new {
    my ($class, $word) = @_;

    my $self = {
        WORD => $word,
        PRON => undef
    };

    bless $self, $class;

    return $self;
}

sub oneline_to_rec {
    my $line = shift;
}

sub save_records {
    my @rec = @{shift};
}

1;
