# $Id$
package OOF::Element::Canvas;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my ($pkg, $filter, %prefs) = @_;
	return $pkg->SUPER::new($filter, \%prefs);
}

1;
