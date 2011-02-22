#!/usr/bin/perl -w
# $Id$

use WASP;
use Webstr;
use warnings;
use strict;

sub t {
	my ($is, @should) = @_;

	foreach my $should (@should) {
		$should =~ s/>\s+</></g;
		$should =~ s/>\s+$/>/sg;
		if ($is eq $should) {
			print "Test succeeded\n";
			return;
		}
	}
	print "\033[1;31mTest failed!\033[1;0;0m\n",
	    "Expected:\n", join("\n", @should),
	    "\n\nGot:\n$is\n";
	die;
}

sub label {
	print @_, ": ";
}

my $wasp = WASP->new;
my $w = Webstr->new($wasp);
my $s;

label "1";
$s = $w->apply("foo");
t $s, "foo";

exit 0;
