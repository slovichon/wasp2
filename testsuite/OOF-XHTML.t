#!/usr/bin/perl -w
# $Id$

use WASP;
use OOF;
use warnings;
use strict;

# Turn on auto-flushing as all data that is printed is important
# and should be displayed.
$|++;

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
test "Regular break";
$e = $oof->br;
print $e, "\n";
_ $e eq "<br />";

test "Interpolated break with attributes";
$e = $oof->br(clear=>"left");
print "$e\n";
_ "$e" eq qq!<br clear="left" />!;

test "Regular code";
$e = $oof->code("some code");
print $e, "\n";
_ $e eq "<code>some code</code>";

test "Code with attributes";
$e = $oof->code({id=>"special"}, "some", " more", " code");
print $e, "\n";
_ $e eq qq!<code id="special">some more code</code>!;

test "Division start";
$e = $oof->div_start();
print $e, "\n";
_ $e eq "<div>";

test "Division with attributes start";
$e = $oof->div_start(align=>"center", style=>"font-weight:bold;");
print $e, "\n";
_ $e eq qq!<div align="center" style="font-weight:bold;">! ||
  $e eq qq!<div style="font-weight:bold;" align="center">!;

test "Division end";
$e = $oof->div_end();
print $e, "\n";
_ $e eq "</div>";

test "Packaged division";
$e = $oof->div();
print $e, "\n";
_ $e eq "<div></div>";

test "Packaged division with attributes and a value";
$e = $oof->div({style=>"font-size:12px;"}, "val");
print $e, "\n";
_ $e eq qq!<div style="font-size:12px;">val</div>!;

test "Regular paragraph";
$e = $oof->p({align=>"justify"}, "sup");
print $e, "\n";
_ $e eq qq!<p align="justify">sup</p>!;

test "Cached paragraph";
$e = $oof->p({align=>"justify"}, "sup");
print "$e\n";
_ $e eq qq!<p align="justify">sup</p>!;

test "Preformatted";
$e = $oof->pre("this is some\nmonospace text");
print "$e\n";
_ $e eq qq!<pre>this is some\nmonospace text</pre>!;

test "Span";
$e = $oof->span({class=>"poppy", style=>"font-size:small;"}, "spanning text");
print $e, "\n";
_ $e eq qq!<span class="poppy" style="font-size:small;">spanning text</span>! ||
  $e eq qq!<span style="font-size:small;" class="poppy">spanning text</span>!;

test "Unordered list_start";
$e = $oof->list_start(OOF::LIST_UN);
print $e, "\n";
_ $e eq qq!<ul>!;

test "Ordered list_start";
$e = $oof->list_start(OOF::LIST_OD, id=>"mylist", lang=>"en-US", style=>"display:box;");
print $e, "\n";
_ $e eq qq!<ol id="mylist" lang="en-US" style="display:box;">! ||
  $e eq qq!<ol id="mylist" style="display:box;" lang="en-US">! ||
  $e eq qq!<ol lang="en-US" id="mylist" style="display:box;">! ||
  $e eq qq!<ol lang="en-US" style="display:box;" id="mylist">! ||
  $e eq qq!<ol style="display:box;" lang="en-US" id="mylist">! ||
  $e eq qq!<ol style="display:box;" id="mylist" lang="en-US">!;

test "Table_start";
$e = $oof->table_start(class=>"foo");
print $e, "\n";
_ $e eq qq!<table class="foo">!;

test "Table_end";
$e = $oof->table_end();
print $e, "\n";
_ $e eq qq!</table>!;

test "Table";
$e = $oof->table({class=>"foobar"},
	["row1col1data", "row1col2data"],
	["row2col1data", "row2col2data"]);
print $e, "\n";
_ $e eq qq!<table class="foobar"><tr>! .
		"<td>row1col1data</td>" .
		"<td>row1col2data</td>" .
	"</tr><tr>" .
		"<td>row2col1data</td>" .
		"<td>row2col2data</td>" .
	"</tr></table>";



exit 0;
