# $Id$
package OOF::Element::Email;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my $pkg    = shift;
	my $filter = shift;

	my ($display, $email);
	if (@_ == 2) {
		($display, $email) = @_;
	} elsif (@_ == 1) {
		($display, $email) = @_[0, 0];
	} else {
		$filter->{wasp}->throw("Bad arguments to OOF::email");
	}

	my $this = $pkg->SUPER::new($filter, {}, $display);

	$this->{email} = $email;

	return $this;
}

1;
