# $Id$
package OF::Form;

use strict;

our $VERSION = 0.1;
our @ISA = qw(OF::Element::Form);

sub new {
	my ($this, $r_prefs, @data) = @_;
	return	$this->start(%$r_prefs) .
		join('', @data) .
		$this->end(%$r_prefs);
}

sub start;
sub end;

return 1;
