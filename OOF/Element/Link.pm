# $Id$
package OOF::Element::Link;

use OOF::Element;
use warnings;
use strict;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

# There are various forms of links:
#
#	(1) $oof->link($name, $url);
#	(2) $oof->link($name);
#	(3) $oof->link(name => $name);
#	(4) $oof->link({href => $url}, $name);
#	(5) $oof->link(href => $url, value => $name);
#
sub new {
	my $pkg    = shift;
	my $filter = shift;
	my $value  = undef;
	my ($prefs, @args);

	if (@_ == 1) {
		# This handles Case #2 above.
		$prefs = { name => $_[0] };
	} elsif (ref $_[0] eq "HASH") {
		# This handles Case #4 above.
		$prefs = shift;
		$value = join '', @_;
	} elsif (@_ == 2) {
		if (defined $_[0] && $_[0] eq "name") {
			# This handles Case #3 above.
			$prefs = { name => $_[1] };
		} else {
			# This handles Case #1 above.
			$prefs = { href => $_[1] };
			$value = $_[0];
		}
	} elsif (@_ > 2) {
		# This handles Case #5 above.
		$prefs = { @_ };
		$value = $prefs->{value};
		delete $prefs->{value};
	} else {
		$filter->throw("Bad arguments to OOF->link()");
	}

	push @args, $prefs;
	push @args, $value if defined $value;

	return $pkg->SUPER::new($filter, @args);
}

1;
