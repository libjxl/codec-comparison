#!/usr/bin/env perl
use strict;
use warnings;

my ($input, $width, $height) = @ARGV;

print 8 * (-s $input) / ($width * $height), "\n";
