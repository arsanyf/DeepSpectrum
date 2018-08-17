#!/usr/bin/perl

use strict;

my @x = ();
while (<>) {
    my @els = split;
    map { s/[^0-9\.]//g } @els;
    push(@x, @els);
}

my $sx = 0;
my $sx2 = 0;
my $n = 0;
for my $x (@x) {
    $sx += $x;
    $sx2 += $x ** 2;
    ++$n;
}
my $mean = $sx / $n;
my $sd = sqrt(($n * $sx2 - $sx ** 2) / ($n * ($n-1)));
printf "%.1f +/- %.1f\n", $mean, $sd;

