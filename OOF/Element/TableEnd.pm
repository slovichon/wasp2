# $Id$
package OOF::Element::TableEnd;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

# This element is of generic end element form.
sub new {
	my $pkg = shift;
	return $pkg->new_end(@_);
}

1;
