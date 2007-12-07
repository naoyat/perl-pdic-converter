package Dictionary::PDICText;

use strict;

use Encode;
use Encode::Guess;

sub new {
    my ($class, $textfile) = @_;
    my $self = {
        FILE => $textfile,
#        MAJOR_VERSION => &Dictionary::PDIC::File::major_version($pdicfile),
        HEADER => undef,
        INDEX => undef,
        INDEX_TREE => undef,

#        INDEX_ABC_TABLE => undef,
#        INDEX_CACHE => undef ## memoize
    };

    bless $self, $class;

    load(0,$textfile);

    return $self;
}

sub load {
    my ($self,$file) = @_;

#    print "file: $file\n";
    open FH, '<', $file;

    my $first_line = <FH>;
    chop $first_line;
    my $format;
    if ($first_line =~ / \/\/\/ /) {
        $format = 'PDIC-1LINE';
    } else {
        $format = 'PDIC-TEXT';
    }
#    $first_line .= <FH>;
#    print $first_line;
    my $input_encoding;
#    my $input_encoding = Encode::Guess::guess_encoding($first_line);
    if (Encode::is_utf8($first_line)) {
        print "utf-8\n";
        $input_encoding = 'utf8';
    } else {
        print "non utf-8\n";
        $input_encoding = 'shiftjis';
    }

    seek FH, 0, 0;
#    read FH, $buf, 2;
    my $enc = find_encoding('shiftjis');
    while (<FH>) {
        chop;
        my ($entry,$description) = /^(.*) \/\/\/ (.*)$/;
#        Encode::from_to($line, $input_encoding, 'utf-8');
#        Encode::from_to($entry, 'shiftjis', 'utf-8');
#        Encode::from_to($description, 'shiftjis', 'utf-8');
        $enc->decode($entry);
        $enc->decode($description);
        printf("> (%s) (%s)\n", $entry, $description);
#        print '.';
    }
    close FH;
}

1;
