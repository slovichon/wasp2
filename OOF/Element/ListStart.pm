# $Id$
package OOF::Element::ListStart;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my ($pkg, $filter, $type, %prefs) = @_;

	my $this = $pkg->new_start($filter, %prefs);

	$this->{type} = $type;

	return $this;
}

1;
