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
			# Create generic element if nonexistent
			eval <<EOC;
				package $class;
				our \@ISA=qw(OOF::Element);
EOC
		}

		# Create method for subsequent invocations
		*$AUTOLOAD = sub {
			return $class->new($this, @_);
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
