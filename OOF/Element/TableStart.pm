# $Id$

package OOF::Element::TableStart;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my $pkg = shift;
	return $pkg->new_start(@_);
}

1;
