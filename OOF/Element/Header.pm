# $Id$
package OOF::Element::Header;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my $pkg = shift;
	my $filter = shift;
	my $prefs = ref $_[0] eq "HASH" ? shift : { };
	my $this = $pkg->SUPER::new($filter, $prefs, join '', @_);
	return $this;
}

1;
