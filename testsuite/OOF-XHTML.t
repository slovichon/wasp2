#!/usr/bin/perl -w
# $Id$

use WASP;
use OOF;
use warnings;
use strict;

sub _ {
	if ($_[0]) {
		print "\033[1;32mTest succeeded\033[1;0;0m\n\n";
	} else {
		print "\033[1;31mTest failed!\033[1;0;0m\n\n";
		die;
	}
} 

sub test {
	print "\033[1;34m", @_, ":\033[1;0;0m\n";
}

my $wasp = WASP->new;
my $oof = OOF->new(filter=>"XHTML", wasp=>$wasp, prefs=>{});

# We have to be careful about the way attributes are built, as
# Perl has never orderly stored hash name/value pairs and does
# so randomly as of 5.8.2.
test "p"; 
print $oof->p({align=>"justify"}, "sup"), "\n";
_ $oof->p({align=>"justify"}, "sup") eq qq!<p align="justify">sup</p>!;

exit 0;
