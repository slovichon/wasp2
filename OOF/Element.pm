# $Id$
# Generic object to be formatted for output
# Conventions:
#	$of->elem(
#		$filter, [ $prefs, ]
#		$str1, $str2, ..., $strN);
#
# The first argument, preferences, is a hash reference to
# key/value pairs containing parameter definitions. The second
# is the output filter the object is associated with. All
# remaining subsequent arguments are concatenated together as
# the main value.
package OOF::Element;

use OOF;
use warnings;
use strict;
use overload
	q[eq] => "eq",
	q[""] => "str",
	q[.]  => "cat";

our $VERSION = 0.1;

# This is a generic handler for most elements.
sub new {
	my $pkg    = shift;
	my $filter = shift;

	# Initialize to default preferences.
	my $prefs;
	my $thispkg = __PACKAGE__;
	(my $elem = $pkg) =~ s/^${thispkg}:://;
	if (ref $filter->{prefs}->{$filter->{abbrs}->{$elem}} eq "HASH") {
		$prefs = { %{ $filter->{prefs}->{$filter->{abbrs}->{$elem}} } };
	} else {
		$prefs = {};
	}
	if (ref $_[0] eq "HASH") {
		my $p = shift;
		@$prefs{keys %$p} = values %$p;
	}

	my $this = bless {
		filter => $filter,
		_before => "",
		_after  => "",
		prefs  => $prefs,
	}, ref($pkg) || $pkg;

	$this->{value} = join '', @_ if @_;

	return ($this);
}

# This is a generic handler for starts of containers.
sub new_start {
	my ($pkg, $filter, %prefs) = @_;

	# Initialize to default preferences.
	my $thispkg = __PACKAGE__;
	(my $elem = $pkg) =~ s/^${thispkg}:://;
	$elem =~ s/Start$//;
	if (ref $filter->{prefs}->{$filter->{abbrs}->{$elem}} eq "HASH") {
		# Load defaults first, so they can be overridden.
		my %p = %{ $filter->{prefs}->{$filter->{abbrs}->{$elem}} };
		@p{keys %prefs} = values %prefs;
		%prefs = %p;
	}

	return bless {
		filter => $filter,
		_before => "",
		_after  => "",

		prefs  => \%prefs,
		value  => "",
	}, ref($pkg) || $pkg;
}

# This is a generic handler for ends of containers.
sub new_end {
	my ($pkg, $filter, %prefs) = @_;

	return bless {
		filter => $filter,
		_before => "",
		_after  => "",

		prefs  => \%prefs,
		value  => "",
	}, ref($pkg) || $pkg;
}

# This is the concatentation operator-overloaded handler.
sub cat {
	my ($this, $arg, $rev) = @_;

	if ($rev) {
		# The arguments have been reversed.
		# ($arg <op> $obj)
		return $arg . "$this";
	} elsif (defined $rev) {
		# The arguments are in normal order.
		# ($obj <op> $arg)
		return "$this" . $arg;
	} else {
		# Concatenation assignment.
		# ($obj .= $arg)
		$this->{_after} .= $arg;
		return "$this";
	}
}

# This is the string interpolation operator-overloaded handler.
sub str {
	my ($this) = @_;

	# Match the containing package prefix so
	# the full element name will be in $'.
	ref($this) =~ /.*::/;

	my $abbr = $this->{filter}{abbrs}{$'};
	@_ = ($this->{filter}, $this);

	no strict 'refs';
	&{ref($this->{filter}) . '::build_' . $abbr};
}

# This is the string equality operator-overloaded handler.
sub eq {
	my ($this, $arg, $rev) = @_;

	# Equality tests should compare the string result.
	return "$this" eq "$arg";
}

1;
