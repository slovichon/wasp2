#!/usr/bin/perl -w
# $Id$

use WASP;
use OOF;
use warnings;
use strict;

sub _ {
	if ($_[0]) {
		print "\033[1;40;32mTest succeeded\033[1;0;0m\n\n";
	} else {
		print "\033[1;40;31mTest failed!\033[1;0;0m\n\n";
		die;
	}
} 

sub test {
	print "\033[1;40;34m", @_, ":\033[1;0;0m\n";
}

my $wasp = WASP->new;
my $oof  = OOF->new(filter=>"XHTML", wasp=>$wasp, prefs=>{});

print $oof->p({align=>"justify"}, "sup");

exit 0;
