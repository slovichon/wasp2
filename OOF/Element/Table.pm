# $Id$
package OOF::Element::Table;

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

	my @rows = @_;
	my $cols = [];

	if (exists $prefs->{cols}) {
		$cols = $prefs->{cols} if ref $prefs->{cols} eq "ARRAY";
		delete $prefs->{cols};
	}

	my $this = $pkg->SUPER::new($filter, $prefs);

	$this->{rows} = \@rows;
	$this->{cols} = $cols;

	return $this;
}

1;
