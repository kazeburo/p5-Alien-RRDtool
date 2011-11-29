#!perl
use strict;
use warnings;

use inc::MyBuilder;
use Module::Build::Compat;
use File::Path qw(rmtree);
use IO::Handle;

use File::Which;
use LWP::Simple;

STDOUT->autoflush(1);

my $name    = 'rrdtool';
my $version = '1.4.5';
my $rrdtool = "http://oss.oetiker.ch/rrdtool/pub/${name}-${version}.tar.gz";

print "# donwloading $rrdtool\n";
print "# => ", scalar mirror($rrdtool, "$name.tar.gz"), "\n";
print "# unpacking $name.tar.gz\n";
system("tar", "xzf",  "$name.tar.gz");
rmtree($name);
rename "$name-$version" => $name;

print "# witing Makefile\n";
my $builder = inc::MyBuilder->new(
    module_name => 'Alien::RRDtool',
    license     => 'perl',
    dist_author => 'Fuji, Goro <fuji.goro@dena.jp>',

    requires    => {
        perl => 5.008_001,
    },

    configure_requires => {
        'File::chdir'   => 0,
        'LWP::Simple'   => 0,
        'Probe::Perl'   => 0,
        'Module::Build' => 0,
    },
    build_requires => {
    },
    test_requires => {
        'Test::More' => 0.88,
        'Test::Requires' => 0.06,
    },
    no_index => {
        directory =>  [
            $name,
            'x',
            'inc',
            'author',
            'benchmark',
        ],
    },

    needs_compiler => 1,
);

$builder->notes( rrdtool => $rrdtool );
$builder->notes( name    => $name    );
$builder->notes( version => $version );

$builder->create_build_script();

# write Makefile for an easy interface to the build script
Module::Build::Compat->write_makefile(build_class => ref $builder);

