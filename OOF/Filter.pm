# $Id$
package OOF::Filter;

use WASP;
use OOF;
use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our $AUTOLOAD;

# Element creation
sub AUTOLOAD {
	my $this = shift;

	(my $element = $AUTOLOAD) =~ s/.*:://;
	if (exists $this->{elements}{$element}) {
		my $class = "OOF::Element::$this->{elements}{$element}";

		no strict 'refs';

		if ($this->{wasp}->has_module($class)) {
			# Specific code exists for this element; use it
			require $class;
		} else {
			# Create generic element if non-existant
			eval <<EOC;
				package $class;
				our \@ISA=qw(OOF::Element);
EOC
		}

		# Create method for subsequent invocations
		*$AUTOLOAD = sub {
			# We don't need $test here because
			#	(1) It is local to this invocation and
			#	    will refer to this variable as opposed
			#	    to that passed it its own call.
			#	(2) The shift hasn't happened yet in this
			#	    invocation and would have to for @_
			#	    to be adjusted correctly.
			return $class->new(@_);
		};

		# Copy/paste of above for speed
		return $class->new($this, @_);
	} else {
		# Not a recognized element
		$this->{wasp}->throw("OF error: no such element; element: $AUTOLOAD");
	}
}

# This is a method that cannot be autoloaded.
sub DESTROY {
}

1;
