#!/usr/bin/perl -w
# $Id$

use WASP;
use Webstr;
use warnings;
use strict;

sub t {
	my ($is, @should) = @_;

	foreach my $should (@should) {
#		$should =~ s/>\s+</></g;
#		$should =~ s/>\s+$/>/sg;
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
$s = $w->apply("hi there <script>hi");
t $s, "hi there &lt;script&gt;hi";

label "2";
$s = $w->apply("hi there <b>hi</b> bye");
t $s, "hi there <b>hi</b> bye";

label "3";
$s = $w->apply("sometimes <i>it</i> is <300MBs");
t $s, "sometimes <i>it</i> is &lt;300MBs";

label "4";
$s = $w->apply("one two <br /> three four");
t $s, "one two <br /> three four";

label "5";
$s = $w->apply("one two <br style='height:700px' /> three four");
t $s, "one two <br  /> three four";

label "6";
$s = $w->apply(q{data <pre  class="foo">test</pre> data});
t $s, q{data <pre  class="foo">test</pre> data};

label "7";
$s = $w->apply(q{data <a  href="http://www.foo.com/blah">FooBar</a> <a  href="http://www.foo2.com/blah">FooBar2</a> data});
t $s,          q{data <a  href="http://www.foo.com/blah">FooBar</a> <a  href="http://www.foo2.com/blah">FooBar2</a> data};

exit 0;
