# $Id$
package OF::Element::Table;

use OF::Element;
use strict;

our $VERSION = 0.1;
our @ISA = qw(OF::Element);

sub new {
	my ($this, $r_prefs, @data) = @_;
	# Preferences are optional
	unless (ref $r_prefs eq "HASH") {
		unshift @data, $r_prefs;
		$r_prefs = {};
	}
	return	$this->start(%$r_prefs) .
		join('', @data) .
		$this->end(%$r_prefs);
}

sub end;
sub start;

return 1;
