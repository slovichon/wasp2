# $Id$

package OOF::Element::TableStart;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

# This element is has a generic start element form.
sub new {
	my ($pkg, $filter, %prefs) = @_;

	my $cols = [];

	# Handle table-specific attributes.
	if ($prefs{cols}) {
		$cols = $prefs{cols} if ref $prefs{cols} eq "ARRAY";
		delete $prefs{cols};
	}

	my $this = $pkg->new_start($filter, %prefs);

	$this->{cols} = $cols;

	return $this;
}

1;
