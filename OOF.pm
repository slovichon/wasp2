# $Id$
package OOF;

use WASP;
use OOF::Element;
use OOF::Filter;
use strict;
use warnings;

our $VERSION = 0.1;

# List types
use constant LIST_OD => 1;
use constant LIST_UN => 2;

sub new {
	my ($class, %prefs) = @_;
	my $wasp   = $prefs{wasp};
	my $filter = $prefs{filter};
	my $prefs  = $prefs{prefs} || {};

	die("No WASP instance specified") unless $wasp;
	$wasp->throw("No output filter specified") unless $filter;

	my $pkg = "OOF::Filter::$filter";
	eval "require $pkg;";
	$wasp->throw("Cannot load OOF filter: $@; filter: $filter") if $@;

	my %elements = (
		br 		=> "Break",
		code		=> "Code",
		div		=> "Division",
		email		=> "Email",
		emph		=> "Emphasis",
		fieldset	=> "Fieldset",
		form		=> "Form",
		header		=> "Header",
		hr		=> "HorizontalRuler",
		img		=> "Image",
		input		=> "Input",
		"link"		=> "Link",
		list		=> "List",
		list_item	=> "ListItem",
		p		=> "Paragraph",
		pre		=> "Preformatted",
		span		=> "Span",
		strong		=> "Strong",
		table		=> "Table",
		table_row	=> "TableRow",
	);

	my %pieces = (
		div_start	=> "DivisionStart",
		div_end		=> "DivisionEnd",
		form_start	=> "FormStart",
		form_end	=> "FormEnd",
		list_start	=> "ListStart",
		list_end	=> "ListEnd",
		table_start	=> "TableStart",
		table_end	=> "TableEnd",
	);

	my %aliases = (
		em		=> "Emphasis",
		image		=> "Image",
		para		=> "Paragraph",
		tr		=> "TableRow",
	);

	return bless {
		wasp		=> $wasp,
		filter		=> $filter,
		prefs		=> $prefs,
		elements	=> {%elements, %pieces, %aliases},
		# "Abbreviations" cannot contain aliases
		# becase the hash is reversed, and there would
		# be conflicting/overwritten keys.
		abbrs		=> {reverse(%elements, %pieces)},
	}, $pkg;
}

1;
