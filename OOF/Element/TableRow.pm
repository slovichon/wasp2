# $Id$
package OOF::Element::TableRow;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my ($pkg, $filter, @cols) = @_;

	my $this = $pkg->SUPER::new($filter);

	$this->{cols} = \@cols;

	return $this;
}

1;
