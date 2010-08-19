# $Id$

=head1 NAME

OOF - object output formatting

=head1 SYNOPSIS

 use WASP;
 use OOF;

 my $wasp = WASP->new();
 my $oof = OOF->new($wasp, $filter[, \%prefs]);
 my $oof = OOF->new(wasp=>$wasp, filter=>$filter[, prefs=>\%prefs]);
 $bool = $oof->in_array($needle, \@hay);

 # Core Elements
 print $oof->br(%prefs);
 print $oof->code([\%prefs, ]@content);
 print $oof->div([\%prefs, ]@content);
 print $oof->email([$title, ]$addr);
 print $oof->email(%prefs);
 print $oof->emph([\%prefs, ]@content);
 print $oof->fieldset(@content);
 print $oof->form(\%prefs, @content);
 print $oof->header([\%prefs, ]@content);
 print $oof->hr(%prefs);
 print $oof->img(%prefs);
 print $oof->input(%prefs);
 print $oof->link(%prefs);
 print $oof->link($title, $href);
 print $oof->list($type, @items);
 print $oof->list_item(@content);
 print $oof->p([\%prefs, ]@content);
 print $oof->pre([\%prefs, ]@content);
 print $oof->span([\%prefs, ]@content);
 print $oof->strong([\%prefs, ]@content);
 print $oof->table(\%prefs, @content);
 print $oof->table_row(@row_cells);

 # Piece-wise Elements
 print $oof->div_start(%prefs);
 print $oof->div_end();
 print $oof->form_start(%prefs);
 print $oof->form_end();
 print $oof->list_start($type);
 print $oof->list_end();
 print $oof->table_start(%prefs);
 print $oof->table_end();

 # Element Aliases
 print $oof->em([\%prefs, ]@content);	# emph
 print $oof->image(%prefs);		# img
 print $oof->tr(@row_cells);		# table_row

=head1 DESCRIPTION

The object output formatting library enables logical elements (objects)
to be formatted in a variety of ways, depending on the output medium
and customized preferences.
It is used directly under another layer of an application and takes
care of the formatting for the target medium, regardless of that medium
(even if the medium is not known in advance).
The layer between the application and OOF should be the application's
layer of defining how the things it outputs should be structured.

For example, a Web page might specify to print out a login form, with
the code looking like this:

	if ($some_condition) {
		print	page_header(),
			login_form(),
			page_footer();
	}

In this example, C<login_form()> would create the HTML (if the target
medium is a Web browser) necessary to show a login form.
Under OOF, it would specify the objects comprising the login form:

	sub login_form {
		my $oof = get_oof_instance_from_somewhere();
		print $oof->form({ method => "post" },
			"Password: ",
			$oof->input(
				type => "password",
				name => "userpw"
			)
		);
	}

In this way, an application depends on what should be output, rather
than how it should be output.
The layer directly below this, the specifications for what elements the
higher-level entities (that the application uses) are made up of, is
where OOF is used.

=cut

package OOF;

use WASP;
use OOF::Element;
use OOF::Filter;
use strict;
use warnings;

our $VERSION = 0.1;

=head1 EXPORTS

=head2 Constants

OOF defines, but does not export, the following constants.

=over

=item C<OOF::LIST_OD>

This constant is used for building lists and is used to specify that
the type of list being built should have its list items prefixed with
their order numbers.

=item C<OOF::LIST_UN>

This constant is used for building lists and is used to specify that
the type of list being built should not have its list items prefixed
with their order numbers.

=back

=cut

# List types
use constant LIST_OD => 1;
use constant LIST_UN => 2;

=head1 METHODS

=over

=item my $oof = OOF-E<gt>new($wasp, $filter[, \%prefs]);

=item my $oof = OOF-E<gt>new(wasp=>$wasp, url_prefix=>$url_prefix, filter=>$filter[, prefs=>\%prefs]);

Create a new OOF instance.
The arguments are:

=over

=item C<$wasp>

A Web Application Structure for Perl (WASP) instance.
See L<WASP>.

=item C<$url_prefix>

An optional prefix that will be prepended to every relative URL.

=item C<$filter>

The output filter target.
All objects will be sent through this filter in order to reach their
finalized forms appropriate for the target medium.
Examples include E<quot>xhtmlE<quot>, E<quot>xmlE<quot>, and
E<quot>textE<quot>.

=item C<\%prefs>

An optional list of element E<quot>preferencesE<quot> that will be
used to for default element E<quot>attributesE<quot> when no
specifics for a given attribute are specified.
Examples include the justification of paragraphs, the size of
page headers, and the border of tables.

This argument must be a hash with element names as keys and their
default preferences as their values in the hash.
The default preferences must be themselves hashes with attribute
names as keys corresponding to the default value for that attribute.

=back

=cut

sub new {
	my $class = shift;
	my @vkeys = qw(wasp filter prefs url_prefix);
	my ($wasp, $filter, $prefs, $url_prefix);
	if ($_[0] && $class->in_array($_[0], \@vkeys)) {
		my %prefs = @_;
		$wasp		= $prefs{wasp};
		$filter		= $prefs{filter};
		$prefs		= $prefs{prefs} || {};
		$url_prefix	= $prefs{url_prefix};
	} else {
		($wasp, $filter, $prefs) = @_;
	}
	$url_prefix = "" unless defined $url_prefix;

	die("No WASP instance specified") unless $wasp;
	$wasp->throw("No output filter specified") unless $filter;

	my $pkg = "OOF::Filter::$filter";
	eval "require $pkg;";
	$wasp->throw("Cannot load OOF filter: $@; filter: $filter") if $@;

	my %elements = (
		br		=> "Break",
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
		link		=> "Link",
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
		tr		=> "TableRow",
	);

	return bless {
		wasp		=> $wasp,
		url_prefix	=> $url_prefix,
		filter		=> $filter,
		prefs		=> $prefs,
		elements	=> {%elements, %pieces, %aliases},
		# "Abbreviations" cannot contain aliases
		# because the hash is reversed, and there would
		# be conflicting/overwritten keys.
		abbrs		=> {reverse(%elements, %pieces)},
	}, $pkg;
}

=item $oof-E<gt>in_array($needle, \@hay);

Determine if the given value C<$needle> appears in the array <@hay>.

=cut

sub in_array {
	my (undef, $needle, $rhay) = @_;
	my $straw;
	foreach $straw (@$rhay) {
		return 1 if $straw eq $needle;
	}
	return 0;
}

=back

=head1 ELEMENTS

There are three different types of elements.
They include the core elements, piece-wise elements, and aliases
for other elements.

=head2 Core Elements

I<Core elements> include the basic set of elements.
They include all simple elements.

=over

=item $oof-E<gt>br(%prefs);

Insert a line break.
The following content will continue on the next line.

=item $oof-E<gt>code([\%prefs, ]@content);

Format the given content as E<quot>codeE<quot>, typed
if it were typed at a prompt.

=item $oof-E<gt>div([\%prefs, ]@content);

Create a logical E<quot>page divisionE<quot>, intended
to be rendered seperately from other content.

=item $oof-E<gt>email([$title, ]$addr);

=item $oof-E<gt>email(%prefs);

Format an e-mail address.

=item $oof-E<gt>emph([\%prefs, ]@content);

Format emphasized text.

=item $oof-E<gt>fieldset(@content);

Format a set of form fields.
All form fields should be placed with in a fieldset.

=item $oof-E<gt>form(\%prefs, @content);

Format a form, i.e., a section or means for gathering user input.

=item $oof-E<gt>header([\%prefs, ]@content);

Format a page header.

=item $oof-E<gt>hr(%prefs);

Format a horizontal ruler.

=item $oof-E<gt>img(%prefs);

Format an image.

=item $oof-E<gt>input(%prefs);

Format a form input field.

=item $oof-E<gt>link(%prefs);

=item $oof-E<gt>link($title, $href);

Format a hyperlink or hyperlink anchor.

=item $oof-E<gt>list($type, @items);

Format a list.

=item $oof-E<gt>list_item(@content);

Format a list item.

=item $oof-E<gt>p([\%prefs, ]@content);

Format a paragraph.

=item $oof-E<gt>pre([\%prefs, ]@content);

Format a section of text that has been preformatted.
That is, the medium will display the given content
exactly how it is given, without any target medium coersion.

=item $oof-E<gt>span([\%prefs, ]@content);

Format a section, or span, of text or content.

=item $oof->strong([\%prefs, ]@content);

Format strong text.

=item $oof-E<gt>table(\%prefs, @content);

Format a table (i.e., container of tabular data).

=item $oof-E<gt>table_row(@row_cells);

Format a row of a table.

=back

=head2 Piece-wise Elements

When elements cannot be fully nested, e.g. during iterative or recursive
output patterns, the following piece-wise routines may be used to
construct output.

=over

=item $oof-E<gt>div_start(%prefs);

=item $oof-E<gt>div_end();

=item $oof-E<gt>form_start(%prefs);

=item $oof-E<gt>form_end();

=item $oof-E<gt>list_start($type);

=item $oof-E<gt>list_end();

=item $oof-E<gt>table_start(%prefs);

=item $oof-E<gt>table_end();

=back

=head2 Element Aliases

These are just name aliases for other elements, providing identical
behavior otherwise.

=head1 BUGS

OOF may seem to be a bit more complicated to use than is necessary;
however, the interface provided is consistent and robust.
There are, of course, deviations from this goal, but this is mostly
the fault of the nature of some of the core elements.

Extending the elements supported by OOF should be much easier.
It at the moment consists of adding an entry to the elements OOF knows
about, creating a filter handler for each desired filter for that
element, and creating a intermediate object definition for that object
capable of remembering information supplied to the object instantiation
by the application.

=head1 AUTHOR

Jared Yanovich E<lt>jaredy@closeedge.netE<gt>.

=cut

1;
