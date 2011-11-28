#!perl -w
use strict;
use Test::More tests => 2;

BEGIN {
    use_ok 'Alien::RRDtool';
    use_ok 'RRDs';
}

diag "Testing Alien::RRDtool/$Alien::RRDtool::VERSION";
diag "RRDs/$RRDs::VERSION";
