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

sub new {
	my $pkg    = shift;
	my $filter = shift;

	my $prefs;
	if (ref $_[0] eq "HASH") {
		$prefs = shift;
	} else {
		$prefs = {};
	}

	my $value  = join '', @_;

	return bless {
		filter => $filter,
		before => "",
		after  => "",

		prefs  => $prefs,
		value  => $value,
	}, ref($pkg) || $pkg;
}

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
		$this->{after} .= $arg;
		return "$this";
	}
}

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

sub eq {
	my ($this, $arg, $rev) = @_;

	# Equality tests should compare the string result.
	return "$this" eq "$arg";
}

1;
