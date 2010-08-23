# $Id$
package OOF::Element::Map;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my $pkg = shift;
	my $filter = shift;
	my $prefs = shift;
	my $value = join '', @_;

	return $pkg->SUPER::new($filter, $prefs, $value);
}

1;
