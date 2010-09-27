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
	my $value;
	my ($prefs, @args);

	if (@_ == 1) {
		# This handles case #2 above.
		$prefs = { name => $_[0] };
	} elsif (ref $_[0] eq "HASH") {
		# This handles case #4 above.
		$prefs = shift;
		$value = join '', @_;
	} elsif (@_ == 2) {
		my $a0 = "" . $_[0];
		if ($a0 eq "name") {
			# This handles case #3 above.
			$prefs = { name => $_[1] };
		} else {
			# This handles case #1 above.
			$prefs = { href => $_[1] };
			$value = $a0;
		}
	} elsif (@_ > 2) {
		# This handles case #5 above.
		$prefs = { @_ };
		$value = $prefs->{value};
		delete $prefs->{value};
	} else {
		$filter->throw("Bad arguments to OOF->link()");
	}

	$prefs->{href} = $filter->{url_prefix} . $prefs->{href} if
	    exists $prefs->{href} and $prefs->{href} =~ m!^/!;

	push @args, $prefs;
	if (defined $value) {
		if (ref $value eq "ARRAY") {
			push @args, @$value;
		} else {
			push @args, $value;
		}
	}

	return $pkg->SUPER::new($filter, @args);
}

1;
