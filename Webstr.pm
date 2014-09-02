# $Id$

=head1 NAME

Webstr - String routines for the Web

=head1 SYNOPSIS

 use Webstr;

 my $w = Webstr->new($wasp);

=head1 DESCRIPTION

=head1 SEE ALSO

L<WASP>

=cut

package Webstr;

use CGI;
use WASP;
use strict;
use warnings;

our $VERSION = 0.1;

sub new {
	my $pkg = shift;
	my $this = {
		allowed_attrs	=> [ qw(href class) ],
		allowed_html	=> [ qw(br p pre tt b i a ol ul li blockquote strong em h1 h2 h3 h4 h5 h6) ],
		allowed_protos	=> [ qw(http https news ftp) ],
		allowed_ents	=> [ qw(amp ndash), '#8220', '#8221', '#8216', '#8217' ],
		attr_protos	=> [ qw(href data src action) ],
		auto_url_tlds	=> [ qw(com co.uk net org gov edu cc de) ],
		auto_urls	=> 1,
		strip_expr	=> 1,
		fix_white	=> 0,
		word_length	=> 30,
	};
	return bless $this, $pkg;
}

sub in_array {
	# XXX sort and bsearch
	my ($needle, $rhay) = @_;
	my $i;
	foreach $i (@$rhay) {
		return 1 if $i eq $needle;
	}
	return 0;
}

# sub encode_html {
#	my ($this, $data) = @_;
#	my %tbl = (
#		'"' => "quot",
#		"'" => "apos",
#		'<' => "lt",
#		'>' => "gt",
#		'&' => "amp",
#	);
#	my $c = qr![^a-zA-Z0-9_`=~\!@#\$%^*()_+\[\]{};:\|.\\,/ -]!;
#	$data =~ s/$c/"&" . (exists $tbl{$&} ? $tbl{$&} : "#" . ord($&)) . ";"/ge;
#	return $data;
# }

# This sub is used by str_parse() to clean up HTML attributes.  It has
# no other immediate usefulness.
sub _str_clean_attr {
	my ($this, $name, $val) = @_;

	# Attributes will have been matched by their delimiters ['"].
	# Note that this should be one of the other; not both.
	$val =~ s/^&quot;(.*)&quot;$/$1/; #xor
	$val =~ s/^'(.*)'$/$1/g;

	# Attributes should have been subjected to htmlEntities().
#	$val = $this->decode_html($val);

	# Strip dangerous "expression()"s in CSS: all tag names with
	# values containing "expression()" are remembered and passed to
	# str_remove_css() which will remove them.
	my @mat;
	if ($name eq "style" && $this->strip_expr &&
	    (@mat = m!([a-zA-Z0-9-]+)\s*:\s*expression\(!ig)) {
		$val = $this->_str_remove_css($val, \@mat);
	}

	return $val;
}

# We're expected to be able to parse something such as:
#
#	$str = qq{
#		foo1:bar1; glarch1:expression(func());
#		foo2:bar2; glarch2:expression(func());
#	}
#
# Given an invocation such as
#
#	$babs->($str, [qw(glarch1 foo2)])
#
# we must guarantee the `glarch1' attribute will be removed cleanly.
sub _str_remove_css {
	my ($this, $str, $ids) = @_;
	my @starts = (0);
	my @stack = ();
	my $len = length $str;
	my $ch;
	my $dquot = 0;
	my $squot = 0;
	my $esc   = 0;

	for (my $i = 0; $i < $len; $i++) {
		$ch = substr $str, $i, 1;
		if ($ch eq ';' && @stack == 0) {
			push @starts, $i+1 if $i+1 < $len;
		} elsif ($ch eq '"') {
			$dquot = !$dquot unless $squot or $esc;
		} elsif ($ch eq "'") {
			$squot = !$squot unless $dquot or $esc;
		} elsif ($ch eq '(' || $ch eq '{' && !$dquot && !$squot) {
			push @stack, $ch;
		} elsif ($ch eq ')' && !$squot && !$dquot) {
			return "" unless pop @stack eq '(';
		} elsif ($ch eq '}' && !$squot && !$dquot) {
			return "" unless pop @stack eq '{';
		} elsif ($ch eq '\\') {
			$esc = !$esc;
			next; # Skip setting $esc to zero
		}
		$esc = 0;
	}

	# We now have an array of starting id indexes
}

#	function newsys_css_remove($ids, $data)
#	{
#		$props	= explode(";", $data);
#		$len	= count($props);
#
#		for ($i = 0; $i < $len; $i++)
#		{
#			list ($name) = explode(":", $props[$i]);
#
#			# Found it, remove property
#			if (in_array($name, $ids))
#				$props[$i--] = $props[--$len];
#		}
#
#		return join(";", $props);
#	}

# This sub is used by str_parse() and is used to check prohibit
# disallowed URI protocols.
sub _str_check_proto {
	my ($this, $url) = @_;

	if ($url =~ /^\s*([a-z]+):/) {
		return in_array($1, $this->allowed_protos);
	}
	return 1;
}

use constant STR_NONE	=> 1 << 0;
use constant STR_HTML	=> 1 << 1;
use constant STR_URL	=> 1 << 2;
use constant STR_ALL	=> STR_HTML | STR_URL;

sub apply {
	my ($this, $str, $flags) = @_;
	$flags = STR_ALL unless defined $flags;

	$str = CGI->escapeHTML($str);

	if ($flags & STR_HTML) {
		# We should probably make an option including leaving
		# alone, blocking, and truncating.

		# Allowed HTML
		my $allowed = lc join "|", @{ $this->allowed_html };
		$str =~	s{
			&lt;			# Escaped tag start
			(			# $1
				/?		# Start/end
				(?i:$allowed)	# Tag name
				\b		# Word boundary
				.*?		# Rest of tag
			)
			&gt;
		}{<$1>}gsx;			# <$tag parse_attr($attr)> ?

		# Allowed attributes
		my $new = $str;
		my $attrs  = $this->allowed_attrs;
		my $protos = $this->attr_protos;
		do {
			$str = $new;
			$new =~	s{
				(				# HTML tag ($1)
					<			# Tag already allowed
					\w+			# Tag name
					(?:\s*\w+=\".*?\")*	# Previously-allowed attributes
					\s?			# Formatting
				)
					\s*			# Whitespace
					(\w+)			# Attribute name ($2)
					\s* = \s*		# Equals
					(			# Attribute ($3) (one of the following)
						&quot;.*?&quot;	# Double quotes (escaped)
						|		# Or
						'.*?'		# Single quotes
						|		# Or
						[^"\s>]+	# Note quotes (bounded by whitespace)
					)
				(				# End of tag ($4)
					.*?			# Rest of tag
					>			# End
				)
			}{
				my ($stag, $attr, $attrval, $etag) = ($1, $2, $3, $4);
				$stag .				# Tag + previous attributes
				(
					# Validate attribute; must be allowed in
					# allowed_attrs, and if of type
					# attr_proto, it is subject to
					# malicious protocol checking
					in_array($attr, $attrs) &&
					(
						in_array($attr, $protos) ?

						# Subject to checking if special attribute
						$this->_str_check_proto(
						    $this->_str_clean_attr($attr, $attrval))

						# Else it's OK
						: 1
					) ?

					# Format attribute
					qq! $2="! . $this->_str_clean_attr($attr, $attrval) . qq!"!

					# It didn't pass; so nothing
					: ""
				) .
				$etag
			}sex;
		} until ($new eq $str);
	}

	if ($flags & STR_URL) {
		if ($this->auto_urls) {
			# If admin specifies which TLDs to check, enforce them.
			# Else any "supposed" TLD will automate.
			my $tlds = @{ $this->auto_url_tlds } ?
			    "(?:" . join "|", @{ $this->auto_url_tlds } . ")\b" :
			    "[a-zA-Z]+";
			# (?= \s | / | $)

			# As variable-length negative lookbehind assertions
			# are unsupported, we will instead save what we
			# don't want to match and assert its absence in the
			# replacement.
			#
			# Note that this is all done relative to HTML
			# formatting.  Perhaps a correct alternative is to
			# parse the output of OF::link() accordingly.
			$str =~	s{
#				(?<!<a\b[^>]+\bhref\s*=\s*[\"']?|<a\b[^>]+\bhref\b[^>]+>)
				(	# URLs we don't want to match ($1)
					# <a href=*URL*
					<a \b [^>]+ \b href \s* = \s* ["']?
					|

					# <a>*URL*</a>
					<a \b [^>]* > (?! .* </a> .* )
					|

					# *URL*
				)
				(	# The URL ($2)
					(?: https?:/{1,3} )?		# Optional HTTP protocol
					(?: www \. )?			# Optional WWW
#					(?! \d+ \. \d+ \b )		# Prevents, e.g., "3.3"
					[a-zA-Z0-9-]
					[a-zA-Z0-9.-]+			# Hostname
					\.
					(?:
						$tlds			# Top-level domain
						(?:			# Optional path
							/ \S*?
							(?=		# URLs hardly containg trailing punctuation
								[,.:;!]+$	# Punctuation at EOL
								|		# Or
								[,.:;!]+\s	# Puncation before space
								|		# Or
								$		# EOL
								|		# Or
								\s		# Space
							)
						)?
#						\S*
					)
				)
			}{
				my $url = $2;
				$1 ? $& :					# If we matched what we don't
										# want to, bail out
				qq!<a href="! .					# Start tag
				( $url =~ m!^http://(?:[^/]|$)! ?
				  "" : "http://" ) .				# Protocol
				(
					$url =~ m!(^http://?/?)?.*/! ?
					$url : "$url/"				# URL/
				) .
				qq!">$3</a>!
			}igex;
		}
	}

	my $ents = $this->allowed_ents;
	if ($ents && @$ents) {
		$str =~	s{&amp;([a-zA-Z0-9]+|#[0-9]+);}{in_array($1, $ents) ? "&$1;" : $&}ge;
	}

	# Fix newlines
	$str =~ s~\r\n | (?<!\r)\n | (?<!\n)\r | \n | \r~<br />~xg if $this->fix_white;

	# Break up long words
	$str =~ s![^\s<>/"']{$this->word_length}!$& !g;

	return $str;
}

sub AUTOLOAD {
	my ($this, @val) = @_;
	our $AUTOLOAD;
	my $field = $AUTOLOAD;
	$field =~ s/.*://;
	die "no such field: $field\n" unless exists $this->{$field};
	return $this->{$field} unless @val;

	if (ref $this->{$field} eq "ARRAY") {
		if (@val == 1 && ref $val[0] eq "ARRAY") {
			$this->{$field} = $val[0];
		} else {
			$this->{$field} = [ @val ];
		}
	} else {
		die "$field is a scalar field\n" if @val != 1;
		$this->{$field} = $val[0];
	}
}

sub DESTROY {
}

1;
