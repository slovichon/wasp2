# $Id$
package OOF::Element::ListEnd;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my ($pkg, $filter, $type) = @_;

	my $this = $pkg->new_end($filter);

	$this->{type} = $type;

	return $this;
}

1;
