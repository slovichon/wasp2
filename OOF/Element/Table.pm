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

	my $prefs = {};
	$prefs = shift if ref $_[0] eq "HASH";

	my @rows = @_;
	my $cols = [];

	if ($prefs->{cols}) {
		$cols = $prefs->{cols} if ref $prefs->{cols} eq "ARRAY";
		delete $prefs->{cols};
	}

	my $this = $pkg->SUPER::new($filter, $prefs);

	$this->{rows} = \@rows;
	$this->{cols} = $cols;

	return $this;
}

1;
