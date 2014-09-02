# $Id$

package OOF::Element::List;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my $pkg    = shift;
	my $filter = shift;

	my $prefs = ref $_[0] eq "HASH" ? shift : { };
	my $type;
	if (%$prefs) {
		$type = $prefs->{type};
		delete $prefs->{type};
	} else {
		$type = shift;
	}

	my $this = $pkg->SUPER::new($filter, $prefs, "");
	$this->{type} = $type;
	$this->{items} = [ @_ ];

	return $this;
}

1;
