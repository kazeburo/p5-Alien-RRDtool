#!perl -w
use strict;
use Test::More;

use Alien::RRDtool;

note( Alien::RRDtool->prefix );

ok -d Alien::RRDtool->prefix;

ok -d Alien::RRDtool->include;
ok -d Alien::RRDtool->lib;
ok -d Alien::RRDtool->share;

ok -x Alien::RRDtool->rrdtool;
ok -x Alien::RRDtool->rrdcached;
ok -x Alien::RRDtool->rrdupdate;

done_testing;
