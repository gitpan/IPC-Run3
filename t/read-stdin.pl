#!perl

use strict;
use warnings;

use Test::More tests => 3;

use blib;
use IPC::Run3;

sub read_stdin
{
    my ($nlines, $run3_after) = @_;

    # read lines from <>, calling run3() after line $run3_after
    my $lineno = 1;
    my $garbled;
    while (<>)
    {
	chomp;
	my $expected = "this is line $lineno";
	$garbled = qq[line $.: expected "$expected", got "$_"]
	    unless $expected eq $_ || $garbled;
	$lineno++;

	if ($lineno == $run3_after)
	{
	    my ($out, $err);
	    run3 [ $^X, "-e", "print qq[some\\nthing]" ], \undef, \$out, \$err;
	    die "command failed" unless $? == 0;
	    is $out, "some\nthing", "STDOUT correctly captured";
	}
    }

    is $lineno-1, $nlines, "STDIN not truncated";
    ok !$garbled, "STDIN not garbled"
	or diag $garbled;

    exit(0);
}

1;
