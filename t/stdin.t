#!perl -w

use Test::More;

use IPC::Run3;
use File::Temp qw(tempfile);
use strict;

## test whether reading from STDIN is affected when
## run3 is called in between

# create a test file for input containing 1000 lines
my $nlines = 1000;
my @exp_lines;
my ($fh, $file) = tempfile(UNLINK => 1);
for (my $i = 1; $i <= $nlines; $i++)
{
    my $line = "this is line $i";
    push @exp_lines, $line;
    print $fh $line, "\n";
}
close $fh;

# call run3 at different lines (a problem might manifest itself 
# on different lines, probably due to different buffering of input)

my @try = (5, 10, 50, 100, 200, 500);
plan tests => (@try * 3) * 2;

my ( $out, $err );
my $data = "some\nthing";

# run3() with input redirected to /dev/null
foreach my $t (@try)
{
    my $nread = 0;
    my $unexpected;
    open STDIN, "<", $file or die "can't open file $file: $!";
    while (<STDIN>)
    {
	chomp;
	$unexpected = qq[line $nread: expected "$exp_lines[$nread]", got "$_"\n]
	    unless $exp_lines[$nread] eq $_ || $unexpected;
	$nread++;

	if ($nread == $t)
	{
	    run3 [ $^X, "-e", "print q[$data]" ], \undef, \$out, \$err;
	    die "command failed" unless $? == 0;
	    is($out, $data, "command output as expected");
	}
    }
    close STDIN;

    is($nread, $nlines, "STDIN was read completely");
    ok(!$unexpected, "STDIN as expected") or diag($unexpected);
}

# run3() with input from a string
foreach my $t (@try)
{
    my $nread = 0;
    my $unexpected;
    open STDIN, "<", $file or die "can't open file $file: $!";
    while (<STDIN>)
    {
	chomp;
	$unexpected = qq[line $nread: expected "$exp_lines[$nread]", got "$_"\n]
	    unless $exp_lines[$nread] eq $_ || $unexpected;
	$nread++;

	if ($nread == $t)
	{
	    run3 [ $^X, '-e', 'print <>' ], \$data, \$out, \$err;
	    die "command failed" unless $? == 0;
	    is($out, $data, "command output as expected");
	}
    }
    close STDIN;

    is($nread, $nlines, "STDIN was read completely");
    ok(!$unexpected, "STDIN as expected") or diag($unexpected);
}


