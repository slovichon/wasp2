# $Id$
package OF::Element::Break;

use OF::Element;
use warnings;
use strict;

our $VERSION = 0.1;
our @ISA = qw(OF::Element);

# An example of break usage may be as follows:
# 	$oof->br(clear=>"right")
# All arguments are name/value parameter descriptions
# instead of the first optional argument. There is no
# value either.
sub new {
	my ($pkg, $filter, %prefs) = @_;

	return bless {
			filter => $filter,
			before => "",
			after  => "",

			prefs  => \%prefs,
			value  => "",
		}, ref($pkg) || $pkg;
}

0;
