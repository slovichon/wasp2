# $Id$
package OOF::Element::FormStart;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

# This element is of generic start element form.
sub new {
	my $pkg = shift;
	return $pkg->new_start(@_);
}

1;
