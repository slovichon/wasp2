#!/usr/bin/perl -w
# $Id$

use WASP;
use OOF;
use warnings;
use strict;

# Turn on auto-flushing as all data that is printed is important
# and should be displayed.
$|++;

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
my $oof = OOF->new(filter=>"XHTML", wasp=>$wasp, prefs=>{});
my $e;

# We have to be careful about the way attributes are built, as
# Perl has never orderly stored hash name/value pairs and does
# so randomly as of 5.8.2.
label "Regular break";
$e = $oof->br();
t $e, "<br />";

label "Interpolated break with attributes";
$e = $oof->br(clear=>"left");
t $e, qq|<br clear="left" />|;

label "Regular code";
$e = $oof->code("some code");
t $e, "<code>some code</code>";

label "Code with attributes";
$e = $oof->code({id=>"special"}, "some", " more", " code");
t $e, qq|<code id="special">some more code</code>|;

label "Division start";
$e = $oof->div_start();
t $e, "<div>";

label "Division with attributes start";
$e = $oof->div_start(align=>"center", style=>"font-weight:bold;");
t $e,	qq|<div align="center" style="font-weight:bold;">|,
	qq|<div style="font-weight:bold;" align="center">|;

label "Division end";
$e = $oof->div_end();
t $e, "</div>";

label "Packaged division";
$e = $oof->div();
t $e, "<div></div>";

label "Packaged division with attributes and a value";
$e = $oof->div({style=>"font-size:12px;"}, "val");
t $e, qq|<div style="font-size:12px;">val</div>|;

label "E-mail";
$e = $oof->email('foo@bar.net');
t $e,	  qq|<script type="text/javascript"><!--\ndocument.writeln(  |
	. qq|'<a href="' + 'mail' + 'to' + ':' + [['foo'].join('&#46;'), |
	. qq|['bar', 'net'].join('&#46;')].join('&#64;') + '">' + |
	. qq|[['foo'].join('&#46;'), ['bar', 'net'].join('&#46;')].join('&#64;') |
	. qq|+ '</a>')// --></script><noscript></noscript>|;

label "Emphasis";
$e = $oof->emph({class=>"super"}, "foo", "bar");
t $e, qq|<em class="super">foobar</em>|;

label "Fieldset";
$e = $oof->fieldset("bleh");
t $e, qq|<fieldset>bleh</fieldset>|;

label "Packaged form";
$e = $oof->form({method=>"post"}, "bleh");
t $e, qq|<form method="post">bleh</form>|;

label "Form start";
$e = $oof->form_start();
t $e, qq|<form>|;

label "Form end";
$e = $oof->form_end();
t $e, qq|</form>|;

label "Header";
$e = $oof->header({size=>2}, "bleh");
t $e, qq|<h2>bleh</h2>|;

label "Horizontal ruler";
$e = $oof->hr();
t $e, qq|<hr />|;

label "Image";
$e = $oof->img(src=>"foo.jpg", alt=>"foobar");
t $e,	qq|<img src="foo.jpg" alt="foobar" />|,
	qq|<img alt="foobar" src="foo.jpg" />|;

label "Select input";
$e = $oof->input(type=>"select", name=>"foobar", options=>{a=>1, b=>2},
		order=>[qw(a b)], value=>2);
t $e, <<END;
<select name="foobar">
	<option value="1">a</option>
	<option value="2" selected="selected">b</option>
</select>
END

label "Text input";
$e = $oof->input(type=>"text", name=>"foobar");
t $e,	qq|<input type="text" name="foobar" />|,
	qq|<input name="foobar" type="text" />|;

label "Textarea input";
$e = $oof->input(type=>"textarea", rows=>8, value=>"bleh bleh bleh");
t $e, qq|<textarea rows="8">bleh bleh bleh</textarea>|;

label "Simple link";
$e = $oof->link("target name", "target URL");
t $e, qq|<a href="target URL">target name</a>|;

label "Anchor name";
$e = $oof->link("name");
t $e, qq|<a name="name"></a>|;

label "Another anchor name";
$e = $oof->link(name => "the a name");
t $e, qq|<a name="the a name"></a>|;

label "Full anchor";
$e = $oof->link(href => "the href", value => "the value", class => "foo");
t $e,	qq|<a href="the href" class="foo">the value</a>|,
	qq|<a class="foo" href="the href">the value</a>|;

label "Standard anchor";
$e = $oof->link({href => "url"}, "foo", "bar");
t $e, qq|<a href="url">foobar</a>|;

label "Unordered list start";
$e = $oof->list_start(OOF::LIST_UN);
t $e, "<ul>";

label "Ordered list start";
$e = $oof->list_start(OOF::LIST_OD, id=>"mylist", lang=>"en-US", style=>"display:box;");
t $e,	qq|<ol id="mylist" lang="en-US" style="display:box;">|,
	qq|<ol id="mylist" style="display:box;" lang="en-US">|,
	qq|<ol lang="en-US" id="mylist" style="display:box;">|,
	qq|<ol lang="en-US" style="display:box;" id="mylist">|,
	qq|<ol style="display:box;" lang="en-US" id="mylist">|,
	qq|<ol style="display:box;" id="mylist" lang="en-US">|;

label "Ordered list end";
$e = $oof->list_end(OOF::LIST_OD);
t $e, "</ol>";

label "List item";
$e = $oof->list_item("simple item");
t $e, "<li>simple item</li>";

label "Regular paragraph";
$e = $oof->p({align=>"justify"}, "sup");
t $e, qq|<p align="justify">sup</p>|;

label "Cached paragraph";
$e = $oof->p({align=>"justify"}, "sup");
t $e, qq|<p align="justify">sup</p>|;

label "Preformatted";
$e = $oof->pre("this is some\nmonospace text");
t $e, qq|<pre>this is some\nmonospace text</pre>|;

label "Span";
$e = $oof->span({class=>"poppy", style=>"font-size:small;"}, "spanning text");
t $e,	qq|<span class="poppy" style="font-size:small;">spanning text</span>|,
	qq|<span style="font-size:small;" class="poppy">spanning text</span>|;

label "Strong";
$e = $oof->strong("b");
t $e, "<strong>b</strong>";

label "Table start";
$e = $oof->table_start(class=>"foo");
t $e, qq|<table class="foo">|;

label "Table end";
$e = $oof->table_end();
t $e, qq|</table>|;

label "Table";
$e = $oof->table({class=>"foobar"},
	["row1col1data", "row1col2data"],
	["row2col1data", "row2col2data"]);
t $e, <<END;
<table class="foobar">
	<tr>
		<td>row1col1data</td>
		<td>row1col2data</td>
	</tr>
	<tr>
		<td>row2col1data</td>
		<td>row2col2data</td>
	</tr>
</table>
END

label "Table2";
$e = $oof->table({class=>"foobar"},
	["row1col1data", {align=>"right", value=>"row1col2data"}],
	["row2col1data", "row2col2data"]);
t $e, <<END;
<table class="foobar">
	<tr>
		<td>row1col1data</td>
		<td align="right">row1col2data</td>
	</tr>
	<tr>
		<td>row2col1data</td>
		<td>row2col2data</td>
	</tr>
</table>
END

exit 0;
