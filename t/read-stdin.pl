#!perl

use strict;
use warnings;

use Test::More tests => 3;
use IPC::Run3;

sub read_stdin
{
    my ($nlines, $run3_after) = @_;

    # read lines from <>, calling run3() after line $run3_after
    my $nread = 0;
    my $garbled;
    while (<>)
    {
	chomp;
	my $expected = "this is line $.";
	$garbled = qq[line $nread: expected "$expected", got "$_"]
	    unless $expected eq $_ || $garbled;
	$nread++;

	if ($nread == $run3_after)
	{
	    my ($out, $err);
	    run3 [ $^X, "-e", "print qq[some\\nthing]" ], \undef, \$out, \$err;
	    die "command failed" unless $? == 0;
	    is $out, "some\nthing", "STDOUT captured correctly";
	}
    }

    is $nread, $nlines, "STDIN truncated?";
    ok !$garbled, "STDIN not garbled?"
	or diag $garbled;

    exit(0);
}

1;
