package Dictionary::PDIC::Dump;
use strict;

use Encode;

#
# dump($pdic, $output_encoding, $output_format)
#
sub dump {
    my ($pdic,$fh,$output_encoding,$output_format) = @_;

    my $cnt = 0;

    my @index = $pdic->index;

#   $pdic->dump_index( @index );

    for (my $i=0; $i<=$#index; $i+=2) {
        my $phys = $index[$i];
        dump_datablock($pdic,$fh,$phys,$output_encoding,$output_format);
    }
}

#
# dump_header($pdic)
#
sub dump_header {
#    my $pdic = shift;
	my ($pdic,$fh) = @_;

    my %header = $pdic->header;
    while ((my $key, my $value) = each(%header)) {
		printf $fh "%s => %s\n", $key, $value;
    }
}

#
# dump_index($pdic, $output_encoding)
#
sub dump_index {
    my ($pdic,$fh,$output_encoding) = @_;
    unless ($output_encoding) {
        $output_encoding = $pdic->is_bocu ? 'utf8' : 'shiftjis';
    }

    my @index = $pdic->index;

    for (my $i=0; $i<=$#index; $i+=2) {
        my $entry = $index[$i+1];

        my $dict_encoding = ($pdic->is_bocu)? 'bocu' : 'shiftjis';
        if ($dict_encoding ne $output_encoding) {
            Encode::from_to($entry, $dict_encoding, $output_encoding);
        }
        printf $fh, "- phys=%d entry=\"%s\"\n", $index[$i], $entry;
    }
}

#
# dump_datablock($pdic, $phys, $output_encoding, $output_format)
#
sub dump_datablock {
    my ($pdic,$fh,$phys,$output_encoding,$output_format) = @_;

    my @result = ();
    my $cnt = 0;

    $pdic->fields_in_datablock( $phys, undef, \@result );
    $cnt += $#result + 1;

    foreach my $ref_field (@result) {
        $pdic->render_field($fh,$ref_field,$output_encoding,$output_format);
    }
}

1;
