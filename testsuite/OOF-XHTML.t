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

test "unordered list_start";
$e = $oof->list_start(OOF::LIST_UN);
print $e, "\n";
_ $e eq qq!<ul>!;

test "ordered list_start";
$e = $oof->list_start(OOF::LIST_OD, id=>"mylist", lang=>"en-US", style=>"display:box;");
print $e, "\n";
_ $e eq qq!<ol id="mylist" lang="en-US" style="display:box;">! ||
  $e eq qq!<ol id="mylist" style="display:box;" lang="en-US">! ||
  $e eq qq!<ol lang="en-US" id="mylist" style="display:box;">! ||
  $e eq qq!<ol lang="en-US" style="display:box;" id="mylist">! ||
  $e eq qq!<ol style="display:box;" lang="en-US" id="mylist">! ||
  $e eq qq!<ol style="display:box;" id="mylist" lang="en-US">!;

test "table_start";
$e = $oof->table_start(class=>"foo");
print $e, "\n";
_ $e eq qq!<table class="foo">!;

test "table_end";
$e = $oof->table_end();
print $e, "\n";
_ $e eq qq!</table>!;

test "table";
$e = $oof->table({class=>"foobar"},
	["row1col1data", "row1col2data"],
	["row2col1data", "row2col2data"]);
print $e, "\n";
_ $e eq qq!<table class="foobar"><tr>! .
	qq!<td>row1col1data</td>! .
	qq!<td>row1col2data</td>! .
	qq!</tr><tr>! .
	qq!<td>row2col1data</td>! .
	qq!<td>row2col2data</td>! .
	qq!</tr></table>!;

exit 0;
