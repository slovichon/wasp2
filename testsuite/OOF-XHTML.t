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
	print "\033[1;34m", @_, ":\033[1;0;0m ";
}

my $wasp = WASP->new;
my $oof = OOF->new(filter=>"XHTML", wasp=>$wasp, prefs=>{});
my $e;

# We have to be careful about the way attributes are built, as
# Perl has never orderly stored hash name/value pairs and does
# so randomly as of 5.8.2.
test "Regular break";
$e = $oof->br();
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

test "E-mail";
$e = $oof->email('foo@bar.net');
print $e, "\n";
_ $e eq   qq~<script type="text/javascript"><!--\ndocument.writeln(  ~
	. qq~'<a href="' + 'mail' + 'to' + ':' + [['foo'].join('&#46;'), ~
	. qq~['bar', 'net'].join('&#46;')].join('&#64;') + '">' + ~
	. qq~[['foo'].join('&#46;'), ['bar', 'net'].join('&#46;')].join('&#64;') ~
	. qq~+ '</a>')// --></script><noscript></noscript>~;

test "Emphasis";
$e = $oof->emph({class=>"super"}, "foo", "bar");
print "$e\n";
_ $e eq qq!<em class="super">foobar</em>!;

test "Fieldset";
$e = $oof->fieldset("bleh");
print $e, "\n";
_ $e eq qq!<fieldset>bleh</fieldset>!;

test "Packaged form";
$e = $oof->form({method=>"post"}, "bleh");
print "$e\n";
_ $e eq qq!<form method="post">bleh</form>!;

test "Form start";
$e = $oof->form_start();
print $e, "\n";
_ $e eq qq!<form>!;

test "Form end";
$e = $oof->form_end();
print $e, "\n";
_ $e eq qq!</form>!;

test "Header";
$e = $oof->header({size=>2}, "bleh");
print $e, "\n";
_ $e eq qq!<h2>bleh</h2>!;

test "Horizontal ruler";
$e = $oof->hr();
print $e, "\n";
_ $e eq qq!<hr />!;

test "Image";
$e = $oof->img(src=>"foo.jpg", alt=>"foobar");
print "$e\n";
_ $e eq qq!<img src="foo.jpg" alt="foobar" />! ||
  $e eq qq!<img alt="foobar" src="foo.jpg" />!;

test "Select input";
$e = $oof->input(type=>"select", name=>"foobar", options=>{a=>1, b=>2},
		order=>[qw(a b)], value=>2);
print $e, "\n";
_ $e eq   qq!<select name="foobar">!
	.	qq!<option value="1">a</option>!
	.	qq!<option value="2" selected="selected">b</option>!
	. qq!</select>!;

test "Text input";
$e = $oof->input(type=>"text", name=>"foobar");
print $e, "\n";
_ $e eq qq!<input type="text" name="foobar" />! ||
  $e eq qq!<input name="foobar" type="text" />!;

test "Textarea input";
$e = $oof->input(type=>"textarea", rows=>8, value=>"bleh bleh bleh");
print $e, "\n";
_ $e eq qq!<textarea rows="8">bleh bleh bleh</textarea>!;

test "Simple link";
$e = $oof->link("target name", "target URL");
print $e, "\n";
_ $e eq qq!<a href="target URL">target name</a>!;

test "Anchor name";
$e = $oof->link("name");
print "$e\n";
_ $e eq qq!<a name="name"></a>!;

test "Another anchor name";
$e = $oof->link(name => "the a name");
print $e, "\n";
_ $e eq qq!<a name="the a name"></a>!;

test "Full anchor";
$e = $oof->link(href => "the href", value => "the value", class => "foo");
print $e, "\n";
_ $e eq qq!<a href="the href" class="foo">the value</a>! ||
  $e eq qq!<a class="foo" href="the href">the value</a>!;

test "Standard anchor";
$e = $oof->link({href => "url"}, "foo", "bar");
print $e, "\n";
_ $e eq qq!<a href="url">foobar</a>!;

test "Unordered list start";
$e = $oof->list_start(OOF::LIST_UN);
print $e, "\n";
_ $e eq qq!<ul>!;

test "Ordered list start";
$e = $oof->list_start(OOF::LIST_OD, id=>"mylist", lang=>"en-US", style=>"display:box;");
print $e, "\n";
_ $e eq qq!<ol id="mylist" lang="en-US" style="display:box;">! ||
  $e eq qq!<ol id="mylist" style="display:box;" lang="en-US">! ||
  $e eq qq!<ol lang="en-US" id="mylist" style="display:box;">! ||
  $e eq qq!<ol lang="en-US" style="display:box;" id="mylist">! ||
  $e eq qq!<ol style="display:box;" lang="en-US" id="mylist">! ||
  $e eq qq!<ol style="display:box;" id="mylist" lang="en-US">!;

test "Ordered list end";
$e = $oof->list_end(OOF::LIST_OD);
print $e, "\n";
_ $e eq qq!</ol>!;

test "List item";
$e = $oof->list_item("simple item");
print $e, "\n";
_ $e eq qq!<li>simple item</li>!;

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
 
test "Strong";
$e = $oof->strong("b");
print "$e\n";
_ $e eq "<strong>b</strong>";

test "Table start";
$e = $oof->table_start(class=>"foo");
print $e, "\n";
_ $e eq qq!<table class="foo">!;

test "Table end";
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
