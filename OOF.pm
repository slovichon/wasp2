# $Id$

=head1 NAME

OOF - object output formatting

=head1 SYNOPSIS

 use WASP;
 use OOF;

 my $wasp = WASP->new();
 my $oof = OOF->new();

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
 print $oof->para([\%prefs, ]@content);	# p
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
		print	$oof->form(
				{ method=>"post" },
				"Password: ",
				$oof->input(type=>"password",
					    name=>"userpw")
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

Create a new OOF instance.
The arguments are:

=over

=item C<$wasp>

A Web Application Structure for Perl (WASP) instance.
See L<WASP>.

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

=back

=cut

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

=back

=head1 BUGS

OOF is somewhat complicated, or at least more complicated than it
otherwise could be.
However, the interface it provides to the user should be consistent
and robust.
There are, of course, deviations from this goal, and this is mostly
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
