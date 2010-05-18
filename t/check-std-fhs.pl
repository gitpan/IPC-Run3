#!perl -w

# this script is called from t/permute-std-fhs.t:
# - copy STDIN to the file given as $ARGV[0]
# - seek to EOF of STDOUT and append the string given as $ARGV[1]
# - seek to EOF of STDERR and append the string given as $ARGV[2]

use strict;
use Fcntl ':seek';

my ($pass, $append_out, $append_err) = @ARGV;

{
    local $/ = undef;
    open my $fh, ">", $pass or die "can't write $pass: $!";
    print $fh <STDIN>;
    close $fh;
}

seek STDOUT, 0, SEEK_END or die "seek STDOUT to end failed: $!";
print STDOUT $append_out;

seek STDERR, 0, SEEK_END or die "seek STDERR to end failed: $!";
print STDERR $append_err;

exit 0;
