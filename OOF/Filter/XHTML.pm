# $Id$
package OOF::Filter::XHTML;

use OOF;
use OOF::Filter;
use warnings;
use strict;

our $VERSION = 0.1;
our @ISA = qw(OOF::Filter);

# There are two ways to have "unescape" routines. One is the naïve
# approach of changing only recognized sequences and the other is
# trying to convert everything.
#
# An example is something like $#8220; -- this could be "unescaped"
# to the corresponding quote letter, but since it would not appear
# in the table, it would not otherwise be converted.

# Non-naïve approach
# sub unescape {
#	shift;
# 	my $str = join '', @_;
#	my %ents = (
#		lt	=> q[<],
#		gt	=> q[>],
#		amp	=> q[&],
#		# apos	=> q['],
#		quot	=> q["],
#	my $ents = join '|', keys %ents;
#	$str =~ s/&($ents);/$ents{$1}/;
#	return $str;
# }

sub escape {
	shift;
	my $str = join '', @_;
	my %ents = (
		q{<} => "lt",
		q{>} => "gt",
		q{&} => "amp",
#		q{'} => "apos",
		q{"} => "quot",
	);
	$str =~ s/[^a-zA-Z0-9`=\[\];',.\/~!@#$%^*()_+{}:?-]/
		exists($ents{$&}) ?
			"&" . $ents{$&} . ";"
		:
			"&#" . ord($&) . ";" /eg;
	return $str;
}

sub _build_GENERIC {
	my ($this, $tag, $obj) = @_;
	my $out = $this->_start_GENERIC($tag, $obj);

	if ($obj->{value} || $tag eq "div" || $tag eq "a") {
		$out .= $obj->{value} . $this->_end_GENERIC($tag, $obj);
	} else {
		# Replace <tag> with <tag />
		$out =~ s!>$! />!;
		$out .= $obj->{after};
	}

	return $out;
}

sub _start_GENERIC {
	my ($this, $tag, $obj) = @_;
	my $out = ($obj->{before} || "") . "<$tag";

	my ($attr, $val);
	while (($attr, $val) = each %{ $obj->{prefs} }) {
		$out .= qq! $attr="$val"!;
	}

	$out .= ">";

	return $out;
}

sub _end_GENERIC {
	my ($this, $tag, $obj) = @_;
	return "</$tag>" . $obj->{after};
}

# Begin element building

sub build_br {
	my ($this, $br) = @_;
	return $this->_build_GENERIC("br", $br);
}

sub build_code {
	my ($this, $code) = @_;
	return $this->_build_GENERIC("code", $code);
}

# This wrapper should never be invoked.
# sub build_div {
#	my ($this, $div) = @_;
# }

sub build_div_start {
	my ($this, $div) = @_;
	return $this->_start_GENERIC("div", $div);
}

sub build_div_end {
	my ($this, $div) = @_;
	return $this->_end_GENERIC("div", $div);
}

sub build_email {
}

# sub build_form {
# }

sub build_form_start {
	my ($this, $form) = @_;
	return $this->_start_GENERIC("form", $form);
}

sub build_form_end {
	my ($this, $form) = @_;
	return $this->_end_GENERIC("form", $form);;
}

sub build_header {
	my ($this, $header) = @_;
}

sub build_hr {
	my ($this, $hr) = @_;
}

sub build_img {
}

sub build_input {
}

sub build_link {
	my ($this, $list) = @_;
}

# This routine is never called.
# sub build_list {
# }

sub build_list_item {
	my ($this, $li) = @_;
	return $this->_build_GENERIC("li", $li);
}

sub build_list_start {
	my ($this, $list) = @_;
	my $type = $list->{type} == OOF::LIST_UN ? "ul" : "ol";
	return $this->_start_GENERIC($type, $list);
}

sub build_list_end {
	my ($this, $list) = @_;
}

sub build_p {
	my ($this, $p) = @_;
	return $this->_build_GENERIC("p", $p);
}

sub build_pre {
	my ($this, $pre) = @_;
	return $this->_build_GENERIC("pre", $pre);
}

sub build_span {
	my ($this, $span) = @_;
	return $this->_build_GENERIC("span", $span);
}

# This routine is never called.
# sub build_table {
# }

sub build_table_start {
	my ($this, $table) = @_;
	return $this->_start_GENERIC("table", $table);
}

sub build_table_end {
	my ($this, $table) = @_;
	return $this->end_GENERIC("table", $table);
}

sub build_table_row {
	my ($this, $tr) = @_;
}

return 1;
