#!perl
use strict;
use warnings;
use File::chdir;
use LWP::Simple;
use File::Which;
use Config;

my $rrdtool = 'http://oss.oetiker.ch/rrdtool/pub/rrdtool-1.4.5.tar.gz';

BEGIN {
    unshift @INC, 'inc';

    # author requires, or bundled modules
    my @devmods = qw(
        inc::Module::Install             1.00
        Module::Install::AuthorTests     0.002
        Module::Install::Repository      0.06
        Test::Requires                   0.06
    );
    my @not_available;
    while(my($mod, $ver) = splice @devmods, 0, 2) {
        eval qq{use $mod $ver (); 1} or push @not_available, $mod;
    }
    if(@not_available) {
        print qq{# The following modules are not available.\n};
        print qq{# `perl $0 | cpanm` will install them:\n};
        print $_, "\n" for @not_available;
        exit 1;
     }
}
use inc::Module::Install;


all_from 'lib/Alien/RRDtool.pm';

configure_requires 'File::chdir';

test_requires 'Test::More'     => '0.88';
test_requires 'Test::Requires' => '0.06';

auto_set_repository;

tests_recursive;
author_tests 'xt';

build_rrdtools($rrdtool);

clean_files qw(
    Alien-RRDtool-*
    *.stackdump
    cover_db *.gcov *.gcda *.gcno
    nytprof
    *.out
);

WriteAll(check_nmake => 0);

sub xsystem {
    my(@args) = @_;
    print join(' ', @args), "\n";
    system(@args) == 0 or die "Failed to system($?): $!";
}

sub build_rrdtools {
    my($url) = @_;

    my($version) =  ( $url =~ m/(\d+ \. \d+ \. \d+)/xms );

    my($xcode) = </Developer/SDKs/MacOSX*>;

    my $libs = "-L/usr/local/lib -L$xcode/usr/lib -lxml2 -lpango-1.0 -lcairo";

    makemaker_args LIBS => $libs;

    mirror($url, "rrdtool-$version.tar.gz");

    local $ENV{PERL} = which($^X);
    local $ENV{CC}   = do {
        my $ccache = which('ccache');
        $ccache ? "$ccache $Config{cc}" : $Config{cc};
    };


    my $prefix = Cwd::abs_path('./x');
    mkdir $prefix;
    xsystem(qq{rm -rf rrdtool-$version/});
    xsystem(qq{tar xzf rrdtool-$version.tar.gz});

    local $CWD = qq{rrdtool-$version};
    xsystem(
        './configure',

        "--prefix=$prefix",
        "--enable-perl-site-install",
        "--with-perl-options=LIBS='$libs'",

        "--disable-tcl",
        "--disable-rrdcgi",
        "--disable-lua",
        "--disable-python",
        "--disable-ruby",
        "--disable-shared",
    );
    xsystem(qq{make install});
}
