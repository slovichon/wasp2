# $Id$
package OOF::Element::Input;

use OOF::Element;
use strict;
use warnings;

our $VERSION = 0.1;
our @ISA = qw(OOF::Element);

sub new {
	my ($pkg, $filter, %prefs) = @_;

	$filter->{wasp}->throw("No type specified to input element") unless $prefs{type};

	my $type;
	$type = $prefs{type};
	delete $prefs{type} if $type eq "select" || $type eq "textarea";

	my ($order, $options, $selected, @vals);
	if ($type eq "select") {
		if (exists $prefs{options}) {
			$options = $prefs{options} if ref $prefs{options} eq "HASH";
			delete $prefs{options};
		}

		if (exists $prefs{order}) {
			$order = $prefs{order} if ref $prefs{order} eq "ARRAY";
			delete $prefs{order};
		}

		if (exists $prefs{value}) {
			$selected = $prefs{value};
			delete $prefs{value};
		}
	} elsif ($type eq "textarea") {
		push @vals, $prefs{value};
		delete $prefs{value};
	}

	my $this = $pkg->SUPER::new($filter, \%prefs, @vals);

	$this->{type} = $type;

	if ($type eq "select") {
		$this->{options} = $options;
		$this->{order} = $order;
		$this->{selected} = $selected;
	}

	return $this;
}

1;
