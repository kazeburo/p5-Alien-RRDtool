package Alien::RRDtool;
use 5.008_001;
use strict;
use warnings;

our $VERSION = '0.01';

1;
__END__

=head1 NAME

Alien::RRDtool - Installation of Perl bindings to RRDtool

=head1 VERSION

This document describes Alien::RRDtool version 0.01.

=head1 SYNOPSIS

    use RRDs; # see RRDtool documentation

=head1 DESCRIPTION

This distribution installs F<RRDs.pm> and F<RRDp.pm> for you.

=head1 DEPENDENCIES

Perl 5.8.1 or later.

RRDtool depends on pkg-config, gettext, glib, xml2, pango and  cairo.
You shuould install those libraries by yourself with a package manager.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<http://oss.oetiker.ch/rrdtool/>

L<RRDs>

L<RRDp>

=head1 AUTHOR

Fuji, Goro (gfx) E<lt>gfuji(at)cpan.orgE<gt>;

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011, Fuji, Goro (gfx). All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
