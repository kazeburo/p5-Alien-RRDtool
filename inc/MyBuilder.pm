package inc::MyBuilder;
use strict;
use warnings;
use parent qw(Module::Build);

use Fatal qw(open);
use Carp;
use Config;
use Cwd;
use File::Path;

use File::chdir;
use File::Which;

sub xsystem {
    my(@args) = @_;
    print "->> ", join(' ', @args), "\n";
    system(@args) == 0 or croak "Failed to system(@args): $!";
}

sub ACTION_code {
    my($self, @args) = @_;

    my $prefix = Cwd::abs_path( $self->notes('installdir') );
    mkpath($prefix);
    {
        local $CWD = $self->notes('name');

        local $ENV{PERL} = $self->perl;
        local $ENV{CC}   = $self->maybe_ccache();
        xsystem(
            './configure',

            "--prefix=$prefix",
            "--enable-perl-site-install",

            "--disable-tcl",
            "--disable-rrdcgi",
            "--disable-perl", # install by myself
            "--disable-lua",
            "--disable-python",
            "--disable-ruby",
            "--disable-shared",
        ) unless -f 'Makefile';

        xsystem($Config{make});
        xsystem($Config{make}, 'install');
    }

    my @libdirs = (
        '/usr/local/lib',
        map { ("$_/usr/lib", "$_/usr/X11/lib") } </Developer/SDKs/MacOSX*>,
    );

    my $libs = do {
        open my $fh, '<', $self->notes('name') . '/Makefile';

        my $libs = '';
        while(<$fh>) {
            if(/ALL_LIBS \s+ = \s+ (.+) /xms) {
                chomp($libs = $1);
            }
        }
        join ' ', (map { "-L$_" } @libdirs),  $libs;
    };

    my $rpath = $self->notes('name') . '/src/.libs';

    $self->perl_bindings(sub {
        xsystem($^X, 'Makefile.PL', "RPATH=$rpath", "LIBS=$libs");
        xsystem($Config{make});
    });

    $self->SUPER::ACTION_build(@args);
}

sub ACTION_test {
    my($self, @args) = @_;

    $self->perl_bindings(sub {
        xsystem($Config{make}, 'test');
    });

    $self->SUPER::ACTION_test(@args);
}

sub ACTION_install {
    my($self, @args) = @_;

    $self->perl_bindings(sub {
        xsystem($Config{make}, 'install');
    });

    $self->SUPER::ACTION_install(@args);
}

sub perl_bindings {
    my($self, $block) = @_;
    for my $path(
            $self->binding_dir('perl-shared'),
            $self->binding_dir('perl-piped')) {

        local $CWD = $path;
        print "In $path:\n";

        $block->();
    }
    return;
}


sub binding_dir {
    my($self, $name) = @_;

    return $self->notes('name') . '/bindings/' . $name;
}

sub maybe_ccache {
    my $cc = $Config{cc};

    return $cc if $cc =~ /ccache/;

    my $ccache = which('ccache');
    return $ccache ? "ccache $cc" : $cc;
}

1;
