# $Id$
package OOF::Element::Header;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my $pkg    = shift;
	my $filter = shift;

	my $prefs = ref $_[0] eq "HASH" ? shift : {};

	my $size;
	if ($prefs->{size} && $prefs->{size} =~ /^\d+$/) {
		$size = $prefs->{size};
		delete $prefs->{size};
	} else {
		$size = 1;
	}

	my $value = join '', @_;

	my $this = $pkg->SUPER::new($filter, $prefs, $value);

	$this->{size} = $size;

	return $this;
}

1;
