# $Id$
package OOF::Element::Break;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

# An example of break usage may be as follows:
#
# 	$oof->br(clear=>"right")
#
# All arguments are name/value parameter descriptions
# instead of the first optional argument.
# There is no value.
sub new {
	my ($pkg, $filter, %prefs) = @_;

	return $pkg->SUPER::new($filter, \%prefs);
}

1;
