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
my $e;

# We have to be careful about the way attributes are built, as
# Perl has never orderly stored hash name/value pairs and does
# so randomly as of 5.8.2.
test "p"; 
$e = $oof->p({align=>"justify"}, "sup");
print $e, "\n";
_ $e eq qq!<p align="justify">sup</p>!;

test "cached p";
$e = $oof->p({align=>"justify"}, "sup");
print "$e\n";
_ $e eq qq!<p align="justify">sup</p>!;

test "pre";
$e = $oof->pre("this is some\nmonospace text");
print "$e\n";
_ $e eq qq!<pre>this is some\nmonospace text</pre>!;

test "span";
$e = $oof->span({class=>"poppy", style=>"font-size:small;"}, "spanning text");
print $e, "\n";
_ $e eq qq!<span class="poppy" style="font-size:small;">spanning text</span>! ||
  $e eq qq!<span style="font-size:small;" class="poppy">spanning text</span>!;

exit 0;
