# $Id$
package OOF::Element::Form;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my $pkg    = shift;
	my $filter = shift;

	# The first argument can optionally be preferences.
	my $prefs = ref $_[0] eq "HASH" ? shift : {};

	my $value = join '', @_;

	my $this = $pkg->SUPER::new($filter, $prefs, $value);

	return $this;
}

1;
