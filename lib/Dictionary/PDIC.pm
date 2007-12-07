package Dictionary::PDIC;

require 5.8.0;
use strict;

use Dictionary::Util::Binary; # bcd_to_dec
use Dictionary::Util::LittleEndian; # get_XXX_value
use Dictionary::PDIC::Version; # major_version

use Dictionary::PDIC::Dump;

##use utf8;
#use Encode::BOCU1;

sub new {
    my ($class, $pdicfile) = @_;
    my $self = {
        FILE => $pdicfile,
        MAJOR_VERSION => &Dictionary::PDIC::Version::major_version($pdicfile),
        HEADER => undef,
        INDEX => undef,
        INDEX_TREE => undef,

        INDEX_ABC_TABLE => undef,
        INDEX_CACHE => undef ## memoize
    };
#    my $proto = shift;
#    my $class = ref($proto) || $proto;
#    my ($pdicfile) = @_;
#    my $pdicfile = shift;

    bless $self, $class;

#    if ($pdicfile) {
#        $self{PDICFILE} = $pdicfile;
#        $self{HEADER} = $self->load_header;
#    }
    return $self;
}

sub file {
    my $self = shift;
    return $self->{FILE};
}
sub header {
    my $self = shift;
    return %{$self->{HEADER}} if $self->{HEADER};
    return %{$self->load_header};
}
sub version {
    my $self = shift;
    my %header = $self->header;

    &bcd_to_dec($header{'version'}) / 100;
}
sub major_version {
    my $self = shift;

    $self->{MAJOR_VERSION};
}
sub is_bocu {
    my $self = shift;
    my %header = $self->header;

    ($header{'dictype'} & 0x08 && $header{'os'} & 0x20) ? 1 : 0;
}
sub load_header {
    my $self = shift;

#    return undef unless $self->{FILE};
#    return $self->{HEADER} if $self->{HEADER};

    #
    # get_pdic_header_buf($self->{pdicfile});
#    my $major_version = major_version($self->file);
#    printf("major version = %d\n", $major_version);

    my $buf;
    open FH, '<', $self->file or die "$self->file:$!";
    read FH, $buf, 256;
    close FH;

    my %values;
    # my @ar = unpack("a100a40ssssssSsssLCCClCSSSSSLlllCC9LCC43", $buf);
    if ($self->major_version == 4) {
        my @ar = unpack("a100a40vvvvvvvvvvVCCCVCvvvvvVVVVCC9VCC43", $buf);
        %values = (
            headername => $ar[0],
            dictitle => $ar[1],
            version => $ar[2],
            word => $ar[3],
            ljapa => $ar[4],
            block_size => $ar[5],
            index_block => $ar[6],
            header_size => $ar[7],
            index_size => $ar[8],
            empty_block => ($ar[9] == 0xffff) ? -1 : $ar[9],
            nindex => $ar[10],
            nblock => $ar[11],
            nword => $ar[12],
            dicorder => $ar[13],
            dictype => $ar[14],
            attrlen => $ar[15],
            olenumber => $ar[16],
            os => $ar[17],
            lid_word => $ar[18],
            lid_japa => $ar[19],
            lid_exp => $ar[20],
            lid_pron => $ar[21],
            lid_other => $ar[22],
            extheader => $ar[23],
            empty_block2 => ($ar[24] == 0xffffffff) ? -1 : $ar[24],
            nindex2 => $ar[25],
            nblock2 => $ar[26],
            index_blkbit => $ar[27],
            reserved => $ar[28],
            update_count => $ar[29],
            charcode => $ar[30],
            dummy => $ar[31]
            );
    } elsif ($self->major_version == 5) {
        my @ar = unpack("a100a40vvvvvvvvvvVCCCCVvvvvvCCVVVVC8VC4C8C32", $buf);
        %values = (
            headername => $ar[0],
            dictitle => $ar[1],
            version => $ar[2],
            word => $ar[3],
            ljapa => $ar[4],
            block_size => $ar[5],
            index_block => $ar[6],
            header_size => $ar[7],
            index_size => $ar[8],
            empty_block => ($ar[9] == 0xffff) ? -1 : $ar[9],
            nindex => $ar[10],
            nblock => $ar[11],
            nword => $ar[12],
            dicorder => $ar[13],
            dictype => $ar[14],
            attrlen => $ar[15],
#        olenumber => $ar[16],
#        os => $ar[17],
            os => $ar[16],
            olenumber => $ar[17],
            
            lid_word => $ar[18],
            lid_japa => $ar[19],
            lid_exp => $ar[20],
            lid_pron => $ar[21],
            lid_other => $ar[22],
            
#        extheader => $ar[23],
#        empty_block2 => $ar[24],
#        nindex2 => $ar[25],
#        nblock2 => $ar[26],
#        index_blkbit => $ar[27],
            index_blkbit => $ar[23],
            dummy0 => $ar[24],
            extheader => $ar[25],
            empty_block2 => ($ar[26] == 0xffffffff) ? -1 : $ar[26],
            nindex2 => $ar[27],
            nblock2 => $ar[28],
            reserved => $ar[29],
            update_count => $ar[30],
            #charcode => $ar[30],
            dummy00 => $ar[31],
            dicident => $ar[32],
            dummy => $ar[33]
            );
    } else {
        %values = ();
    }
#    print %values;
    $self->{HEADER} = \%values;
    \%values;
}

sub index {
    my $self = shift;
    return @{$self->{INDEX}} if $self->{INDEX};
    return @{$self->load_index};
}
sub load_index {
    my $self = shift;
    my %header = $self->header;

    open FH, '<', $self->file or die "$self->file:$!";
    seek FH, $header{'header_size'} + $header{'extheader'}, 0;

    my $index_block = $header{'index_block'};
    my $nindex = $header{'nindex2'};
    my $index_blkbit = $header{'index_blkbit'};
    my $index_blkbyte = ($header{'index_blkbit'} == 1) ? 4 : 2;

#    printf("number of indices: %d\n", $nindex);
#    printf("index blkbit: %d\n", $index_blkbyte << 3);
#    printf("index buffer size: %d\n", $header{'index_block'} << 8);

    my $buf = '';
    my $ofs = 0, my $n = 0;
    my @ar = ();
    for (my $i=0; $i<$index_block; $i++) {
        my $buf2;
        read FH, $buf2, 256;
        $buf .= $buf2;
        $buf .= '\0' x 256 if $i == $index_block - 1;
        while (length($buf) >= 253) {
            my $phys;
            if ($index_blkbit == 1) {
                $phys = get_ulong_value($buf);
            } else {
                $phys = get_ushort_value($buf);
            }
            $buf = substr($buf, $index_blkbyte);
            $ofs += $index_blkbyte;
            my $entry = get_cstring($buf); #unpack("Z*", $buf);

#            $ar[$n] = [$phys,$entry,$ofs];
#            $ar[$n] = [$phys,$entry];
            $ar[$n*2] = $phys;
            $ar[$n*2+1] = $entry;
            $n++;
#            printf("%d (%d)(%d) %s\n", $n, $ofs, $phys, $entry);

            my $bytes = length($entry) + 1;
            $buf = substr($buf, $bytes);
            $ofs += $bytes;

            last if $n == $nindex;
        }
        last if $n == $nindex;
    }
    close FH;
    
    $self->{INDEX} = \@ar;
    \@ar;
}
sub create_index_abc_table {
    my $self = shift;
    my @ar = ();

    my @index = $self->index;
#    printf("index : %d .. %d\n", 0, $#index);
#    printf("  (%s %s)\n", $index[0], $index[1]);
    printf("  %d (%d:'%s') .. %d (%d:'%s')\n",
           0, $index[0], $index[1],
           $#index-1, $index[$#index-1], $index[$#index]);

    my $first_char = ord($index[1]); # ord(first_word)
    my $last_char = ord($index[$#index]); # ord(last_word)
    for (my $i=0; $i<$first_char; $i++) {
        $ar[$i*2] = $ar[$i*2+1] = -1;
    }
    for (my $i=$last_char+1; $i<256; $i++) {
        $ar[$i*2] = $ar[$i*2+1] = -1;
    }
    for (my $i=$first_char; $i<=$last_char; $i++) {
        my $c = chr($i);
        my $ix = $self->index_search_peer($c);
        my $c_ff = chr($i) . chr(255);
        my $ix_ff = $self->index_search_peer($c_ff);
        printf("%02x --> (%d .. %d)\n", $i, $ix, $ix_ff);
    }

#    for (my $i=0; $i<256; $i++) {
#        my $c = chr($i);
#        my $ix = $self->index_search_peer($c);
#        my $c_ff = chr($i) . chr(255);
#        my $ix_ff = $self->index_search_peer($c_ff);
#        printf("%02x --> (%d .. %d)\n", $i, $ix, $ix_ff);
#    }
    $self->{INDEX_ABC_TABLE} = \@ar;
    \@ar;
}

sub index_search_peer {
    my ($self,$needle) = @_;
    my @index = $self->index;

    for (my $i=$#index; $i>0; $i-=2) {
        my $entry = $index[$i];
        next if $needle lt $entry; #skip until
#        return [$index[$i-1],$index[$i]] if $entry le $needle;
#        return $i if $entry le $needle;
        return $i;
#        return $index[$i-1] if $entry le $needle;
    }
    return -1;
}
sub index_search {
    my ($self,$ref_cond) = @_;
    my @index = $self->index;

    my %cond = %$ref_cond;
#    while ((my $key, my $value) = each(%$ref_cond)) {
#        printf("%s => %s\n", $key, $value);
#    }
#    print $cond{upper_limit} . "\n";

    my $lower = index_search_peer($self,$cond{lower_limit});
    return () if $lower < 0;
    return ( $index[$lower-1] ) unless $cond{upper_limit};

#    my $needle_len = length($needle);
#    my $upper_limit = substr($needle,0,$needle_len-1) . chr(ord(substr($needle,$needle_len-1,1))+1);
#    my $upper_limit = ;
#    print "$upper_limit\n";

    my $upper = index_search_peer($self,$cond{upper_limit});
    my @ar = ();
    for (my $i=$lower; $i<=$upper; $i+=2) {
        push(@ar,$index[$i-1]);
    }
    return @ar;
}

sub get_datablock_addr {
    my ($self,$phys) = @_;

    return undef if $phys < 0;

    my %header = $self->header;
    my $addr = $header{'header_size'} + $header{'extheader'} +
        ($header{'index_block'} << 8) + ($phys << 8);

#    printf("%x\n", $addr);
    $addr;
}

sub fields_in_datablock {
    my ($self,$phys,$ref_cond,$ref_result) = @_;

    my $is_aligned = ($self->major_version == 5) ? 1 : 0;

    my %cond;
    if (defined($ref_cond)) {
        %cond = %$ref_cond;
    } else {
        %cond = ();
    }

#    my @result = @$ref_result;
    my $result_count = 0;

#    printf("%d => %x\n", $phys, $self->get_datablock_addr($phys)); ##
    
    open FH, '<', $self->file or die "$self->file:$!";
    seek FH, $self->get_datablock_addr($phys), 0;

    my $buf;
    read FH, $buf, 2;
    my $used_blocks = get_ushort_value($buf,0);

    my $field_length_byte;
    if ($used_blocks & 0x8000) {
        $field_length_byte = 4;
        $used_blocks &= 0x7fff;
    } else {
        $field_length_byte = 2;
    }
#    printf("block length = %d, field length byte = %d\n", $used_blocks, $field_length_byte);
    if ($used_blocks == 0) {
        print "Detected an emptyblock. ";

        read FH, $buf, 4;
        my $next_emptyblock = get_ulong_value($buf);
        # $buf = substr($buf,4);
        printf("Next emptyblock at %x\n", $next_emptyblock);
        close FH;
        return 0;
    }

    my $datablock_length = ($used_blocks << 8) - 2;
    my $rest = $datablock_length;
#    $block_length--;
#    my $buf_rest = 254;

#    printf("%d + %d\n", $buf_rest, $block_length << 8);
    my $entry_base = '';
    while ($rest > 0) {
#        printf("[%d / %d]\n", $rest, $datablock_length);
        # read a chunk
#        read FH, $buf, $field_length_byte + 1;
        if ($is_aligned) {
            read FH, $buf, $field_length_byte + 2;
        } else {
            read FH, $buf, $field_length_byte + 1;
        }
        my $field_length = get_unsigned_value($buf,0,$field_length_byte);
        last if $field_length == 0;

        my $ofs = $field_length_byte;
        my $compressed_length = get_uchar_value($buf,$ofs++);
        my $entry_attr;
        if ($is_aligned) {
            $entry_attr = get_uchar_value($buf,$ofs++); ## 5
            last unless $entry_attr & 0x80;
            $entry_attr &= 0x7f;
        }
#        $rest -= $field_length_byte + 1;
        $rest -= $ofs;
#        printf("C-L:%d, attr=%x \n", $compressed_length, $entry_attr);

#    my $entry = unpack("Z*", $buf);
        read FH, $buf, $field_length;
        $ofs = 0;
        my $compressed_entry = get_cstring($buf, $ofs);
        $ofs += length($compressed_entry) + 1;
        my $entry = substr($entry_base,0,$compressed_length) . $compressed_entry;
        $entry_base = $entry;
        unless ($is_aligned) {
            $entry_attr = get_uchar_value($buf,$ofs++);
            last unless $entry_attr & 0x80;
            $entry_attr &= 0x7f;
        }

        my $trans;
        my %ext_contents = ();
        if ($entry_attr & 0x10) {
            # extended
            $trans = get_cstring($buf,$ofs);
            $ofs += length($trans) + 1;
            
            while (1) {
                my $ext_attr = get_uchar_value($buf,$ofs++);
                last if $ext_attr == 0x80;

                my $flags = ($ext_attr >> 8) & 0x07;
                my $ext_content;
                if ($flags == 0) {
                    # no flags
                    $ext_content = get_cstring($buf,$ofs);
                    $ofs += length($ext_content) + 1;
                } elsif ($flags == 1) {
                    # BINARY_DATA
                    my $size = get_unsigned_value($buf,$ofs,$field_length_byte);
                    $ofs += $field_length_byte;
                    $ext_content = substr($buf,$ofs,$size);
                    $ofs += $size;
                } elsif ($flags == 5) {
                    # COMPRESSED_DATA | BINARY_DATA
                    my $size = get_unsigned_value($buf,$ofs,$field_length_byte);
                    $ofs += $field_length_byte;
                    my $rawdata_length = get_uchar_value($buf,$ofs);
                    $ofs++;
                    my $rawdata = substr($buf,$ofs,$rawdata_length);
                    $ofs += $rawdata_length;
                    my $compressed_data = substr($buf,$ofs,$size-1-$rawdata_length);

                    $ext_content = $rawdata; ## 
                }

                if ($ext_attr == 1) {
                    $ext_contents{example} = $ext_content;
                } elsif ($ext_attr == 2) {
                    $ext_contents{pron} = $ext_content;
                } elsif ($ext_attr == 4) {
                    $ext_contents{link} = $ext_content;
                } else {
                    $ext_contents{$ext_attr} = $ext_content;
                }
#                push(@ext_contents, \($ext_attr,$ext_content));
            }
        } else {
            # normal
            $trans = substr($buf,$ofs,$field_length - $ofs);
        }
    
#        printf("field length : %d bytes\n", $field_length);
#        printf("compressed_length : %d bytes\n", $compressed_length);
#        printf("entry : %s\n", $entry);
#        printf("entry attr : %x\n", $entry_attr);
#        printf("trans : %s\n", $trans);
#        printf("ext_contents : %d\n", $#ext_contents);
#         printf("%s /// %s\n", $entry, $trans);
        if ((%cond && $cond{lower_limit} le $entry && $entry le $cond{upper_limit})
            || (! %cond)) {
            my %field = ( entry => $entry,
                          entry_attr => $entry_attr,
                          trans => $trans,
                          ext_contents => \%ext_contents
                );
            push(@$ref_result, \%field);
            $result_count++;
        }

#        $buf = substr($buf, $field_length);
        $rest -= $field_length;
#        $ofs = 0;
    }
    close FH;

    $result_count;
}

#
# render_field(\$field, $output_encoding [,$output_format])
#
sub render_field {
    my ($self,$ref_field,$output_encoding,$output_format) = @_;
#    my $is_bocu = $self->is_bocu;

    my %field = %{$ref_field};

    my $entry = $field{entry};
    my $trans = $field{trans};

    my %ext_contents = %{$field{ext_contents}};
    my $pron;
    my $example;
    if (keys(%ext_contents) > 0) {
        $pron = $ext_contents{'pron'};
        $example = $ext_contents{'example'};
    }

    my $dict_encoding = ($self->is_bocu)? 'bocu1' : 'shiftjis';
    if ($dict_encoding ne $output_encoding) {
        Encode::from_to($entry, $dict_encoding, $output_encoding);
        Encode::from_to($trans, $dict_encoding, $output_encoding);
        Encode::from_to($example, $dict_encoding, $output_encoding) if $example;
    }

    if ($output_format eq 'PDIC-TEXT') {
        $trans =~ s/\015\n/ \\ /g;

        printf("%s\n", $entry);
        if ($example) {
            printf("%s / %s\n", $trans, $example);
        } else {
            printf("%s\n", $trans);
        }
    } elsif ($output_format eq 'PDIC-1LINE') {
        $trans =~ s/\015\n/ \\ /g;
        if ($example) {
            printf("%s /// %s / %s\n", $entry, $trans, $example);
        } else {
            printf("%s /// %s\n", $entry, $trans);
        }
    } elsif ($output_format eq 'TAB') {
        $trans =~ s/\015\n/ \\ /g;
        printf("%s\t%s\t%s\n", $entry, $trans, $example);
    } elsif ($output_format eq 'CSV') {
#        $trans =~ s/\015\n/ \\ /g;
        $trans =~ s/"/\\"/g;
        printf("\"%s\",\"%s\",\"%s\"\n", $entry, $trans, $example);
    } else {
        if ($pron) {
            printf("%s [%s]\n", $entry, $pron);
        } else {
            printf("%s\n", $entry);
        }
        $trans =~ s/\015\n/\n\t/g;
        printf("\t%s\n", $trans);
        printf("\t%s\n", $example);
    }
}

##
## Dump... (defined in PDIC::Dump)
##
sub dump {
    my ($self,$output_encoding,$output_format) = @_;
    Dictionary::PDIC::Dump::dump($self,$output_encoding,$output_format);
}
sub dump_header {
    my $self = shift;
    Dictionary::PDIC::Dump::dump_header($self);
}
sub dump_index {
    my ($self,$output_encoding) = @_;
    Dictionary::PDIC::Dump::dump_index($self,$output_encoding);
}
sub dump_datablock {
    my ($self,$phys,$output_encoding,$output_format) = @_;
    Dictionary::PDIC::Dump::dump_datablock($self,$phys,$output_encoding,$output_format);
}

1;
