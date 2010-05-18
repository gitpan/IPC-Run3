#!perl -w

use Test::More;

use IPC::Run3;
use strict;

my @std_fhs =
(
    { fh => \*STDIN,  name => "STDIN",  file => "t/in.txt",  text => "IN1\nIN2\nIN3\n"    },
    { fh => \*STDOUT, name => "STDOUT", file => "t/out.txt", text => "OUT1\nOUT2\nOUT3\n" },
    { fh => \*STDERR, name => "STDERR", file => "t/err.txt", text => "ERR1\nERR2\nERR3\n" },
);

my @perms =
(
    [ 0, 1, 2 ],
    [ 0, 2, 1 ],
    [ 1, 0, 2 ],
    [ 1, 2, 0 ],
    [ 2, 0, 1 ],
    [ 2, 1, 0 ],
);

plan tests => @perms * @std_fhs;


# set up an element of @std_fhs for testing:
# write TEXT to FILE, then open "+<" FILE as FH
sub setup
{
    my ($t) = @_;

    unlink $t->{file};
    open my $fh, ">", $t->{file} or die "can't write $t->{file}: $!";
    print $fh $t->{text};
    close $fh;

#   eval "open $t->{name}, '+<', '$t->{file}'" or die "can't open $t->{file} for rw: $!";
    open $t->{fh}, "+<", $t->{file} or die "can't open $t->{file} for rw: $!";
}

# check that a file has the expected contents
sub check
{
    my ($file, $expected, $msg) = @_;

    local $/ = undef;
    open my $fh, "<", $file or die "can't read $file: $!";
    my $got = <$fh>;
    close $fh;

    is($got, $expected, $msg);
}

# call run3 with the given permutation of std filehandles,
# check for expected file contents (3 tests per call)
sub test_perm
{
    my @permuted_fhs = map { $std_fhs[$_] } @_;

    my ($pass, $append_out, $append_err) = ("t/pass.txt", "append_OUT", "append_ERR");

    setup($_) for @permuted_fhs;

    unlink $pass;
    run3 [ $^X, "t/check-std-fhs.pl", $pass, $append_out, $append_err ],
         map { $_->{fh} } @permuted_fhs;
    die "script t/check-std-fhs.pl failed" unless $? == 0;

    check($pass,                  $permuted_fhs[0]{text},
          "permutation @_: STDIN of child");
    check($permuted_fhs[1]{file}, $permuted_fhs[1]{text}.$append_out,
          "permutation @_: STDOUT of child");
    check($permuted_fhs[2]{file}, $permuted_fhs[2]{text}.$append_err,
          "permutation @_: STDERR of child");
}

test_perm(@$_) foreach @perms;

exit 0;

