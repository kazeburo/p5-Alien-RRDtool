#!perl
use strict;
use warnings;

use inc::MyBuilder;
use Module::Build::Compat;
use File::Path qw(rmtree);
use IO::Handle;

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
    dist_author => 'Fuji, Goro (gfx) <gfuji(at)cpan.org>',

    requires    => {
        perl => 5.008_001,

        'File::ShareDir' => 0,
    },

    configure_requires => {
        'File::chdir'   => 0,
        'File::Which'   => 0,
        'LWP::Simple'   => 0,
        'Module::Build' => 0,
    },
    build_requires => {
        'File::ShareDir' => 0,
    },
    test_requires => {
        'Test::More'     => 0.88,
        'Test::Requires' => 0.06,
    },

    #share_dir => 'share',

    needs_compiler => 1,

    no_index => {
        directory =>  [
            'x',
            'inc',
            'author',
        ],
    },

    add_to_cleanup => [$name, "$name.tar.gz", 'Makefile'],
);

$builder->notes( rrdtool    => $rrdtool );
$builder->notes( name       => $name    );
$builder->notes( version    => $version );
$builder->notes( installdir => $builder->blib . '/rrdtool' );

$builder->create_build_script();

# write Makefile for an easy interface to the build script
Module::Build::Compat->write_makefile(build_class => ref $builder);

