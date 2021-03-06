# $Id$
package OOF::Filter::XHTML;

use OOF;
use OOF::Filter;
use warnings;
use strict;

our $VERSION = 0.1;
our @ISA = qw(OOF::Filter);

# There are two ways to have "unescape" routines. One is the na�ve
# approach of changing only recognized sequences and the other is
# trying to convert everything.
#
# An example is something like $#8220; -- this could be "unescaped"
# to the corresponding quote letter, but since it would not appear
# in the table, it would not otherwise be converted.

# Non-na�ve approach
# sub unescape {
#	shift;
#	my $str = join '', @_;
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
		:	"&#" . ord($&) . ";" /eg;
	return $str;
}

sub _build_GENERIC {
	my ($this, $tag, $obj) = @_;
	my $out = $this->_start_GENERIC($tag, $obj);

	my $v = $obj->{value};
	$v = join '', @{ $obj->{value} } if ref $v eq "ARRAY";
	$v = $obj->{_value}->($v) if exists $obj->{_value};

	if (defined $v || $tag eq "div" ||
	    $tag eq "a" || $tag eq "textarea") {
		$out .= $v if defined $v;
		$out .= $this->_end_GENERIC($tag, $obj);
	} else {
		# Replace "<tag>" with "<tag />".
		$out =~ s!>$! />!; #!
	}
	$out .= $obj->{_after};

	return $out;
}

sub _start_GENERIC {
	my ($this, $tag, $obj) = @_;
	my $out = ($obj->{_before} || "") . "<$tag";

	my ($attr, $val);
	while (($attr, $val) = each %{ $obj->{prefs} }) {
		$out .= qq! $attr="$val"!;
	}

	$out .= ">";

	return $out;
}

sub _end_GENERIC {
	my ($this, $tag, $obj) = @_;
	return "</$tag>" . $obj->{_after};
}

# Begin element building

sub build_area {
	my ($this, $area) = @_;
	return $this->_build_GENERIC("area", $area);
}

sub build_br {
	my ($this, $br) = @_;
	return $this->_build_GENERIC("br", $br);
}

sub build_canvas {
	my ($this, $canvas) = @_;
	return $this->_build_GENERIC("canvas", $canvas);
}

sub build_code {
	my ($this, $code) = @_;
	return $this->_build_GENERIC("code", $code);
}

sub build_div {
	my ($this, $div) = @_;
	return $this->_build_GENERIC("div", $div);
}

sub build_div_start {
	my ($this, $div) = @_;
	return $this->_start_GENERIC("div", $div);
}

sub build_div_end {
	my ($this, $div) = @_;
	return $this->_end_GENERIC("div", $div);
}

sub build_email {
	my ($this, $email) = @_;

	my ($var);
	my $jsemail = "email";
	my $jsdisplay = "value";
	foreach $var ($jsemail, $jsdisplay) {
		my @parts = split /@/, $email->{$var};
		$var = "[";
		my ($part, @subparts, $subpart);
		foreach $part (@parts) {
			@subparts = split /\./, $part;

			$var .= "[";
			foreach $subpart (@subparts) {
				$var .= qq~'$subpart', ~;
			}
			$var =~ s/, $//;
			$var .= "].join('&#" . ord('.'). ";'), ";
		}
		$var =~ s/, $//;
		$var .= "].join('&#" . ord('@') . ";')";
	}

	return	qq~<script type="text/javascript">~
	.		qq~<!--\n~
	.			qq~document.writeln(~
	.				qq~  '<a href="'~
	.				qq~ + 'mail'~
	.				qq~ + 'to'~
	.				qq~ + ':'~
	.				qq~ + $jsemail~
	.				qq~ + '">'~
	.				qq~ + $jsdisplay~
	.				qq~ + '</a>'~
	.			qq~)~
	.		qq~// -->~
	.	qq~</script>~
	.	qq~<noscript>~
			# XXX: <noscript> e-mail address
	.		qq~~
	.	qq~</noscript>~
	;
}

sub build_emph {
	my ($this, $emph) = @_;
	return $this->_build_GENERIC("em", $emph);
}

sub build_fieldset {
	my ($this, $fieldset) = @_;
	return $this->_build_GENERIC("fieldset", $fieldset);
}

sub build_form {
	my ($this, $form) = @_;

	return    $this->build_form_start($form)
		. $form->{value}
		. $this->build_form_end($form);
}

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
	my $size = 1;
	my %p = %$header;
	if (exists $p{prefs}{size}) {
		$size = $p{prefs}{size};
		delete $p{prefs}{size};
	}
	return $this->_build_GENERIC("h$size", \%p);
}

sub build_hr {
	my ($this, $hr) = @_;
	return $this->_build_GENERIC("hr", $hr);
}

sub build_img {
	my ($this, $img) = @_;
	if (exists $img->{prefs}{svg}) {
		my %p = %$img;
		my $svg = $p{prefs}{svg};
		delete $p{prefs}{svg};
		my $reg = $this->_build_GENERIC("img", \%p);

		$p{prefs}{src} = $svg;
		$svg = $this->_build_GENERIC("img", \%p);

		return "<script type='text/javascript'>" .
		    "if (window.SVGSVGElement) { " .
			qq{ document.write('$svg')} .
		    " } else {" .
			" document.write('$reg')" .
		    " }" .
		    "</script>" .
		    "<noscript>$reg</noscript>";
	}
	return $this->_build_GENERIC("img", $img);
}

sub build_input {
	my ($this, $input) = @_;

	my $tag;
	if ($input->{type} eq "select") {
		$tag = "select";

		$input->{value} = "";
		if ($input->{options}) {
			if (ref $input->{order} eq "ARRAY") {
				my ($optkey, $optval);
				foreach $optkey (@{ $input->{order} }) {
					$optval = $input->{options}->{$optkey};
					$input->{value} .= qq!<option value="$optval"!
							.  ($input->{selected} eq $optval ? qq! selected="selected"! : "")
							.  qq!>$optkey</option>!;
				}
			} else {
				# Use randomized ordering.
				my ($optkey, $optval);
				while (($optkey, $optval) = each %{ $input->{options} }) {
					$input->{value} .= qq!<option value="$optval"!
							.  ($input->{selected} eq $optval ? qq! selected="selected"! : "")
							.  qq!>$optkey</option>!;
				}
			}
		}
	} elsif ($input->{type} eq "textarea") {
		$tag = "textarea";
	} else {
		$tag = "input";
		$input->{prefs}->{type} = $input->{type};
	}

	return $this->_build_GENERIC($tag, $input);
}

sub build_label {
	my ($this, $label) = @_;
	return $this->_build_GENERIC("label", $label);
}

sub build_link {
	my ($this, $link) = @_;
	if ($link->{prefs}{href} &&
	    $link->{prefs}{href} =~ /^mailto:/) {
		my $s = $this->_build_GENERIC("a", $link);
		my $v = join ',', map {
			sprintf("%#x", ord($_)) } split /(?=.)/, $s;
		return <<EOF;
	<script type="text/javascript"><!--
		document.writeln(String.fromCharCode($v))
	//-->
	</script>
EOF
	} else {
		return $this->_build_GENERIC("a", $link);
	}
}

sub build_list {
	my ($this, $list) = @_;
	my $output = $this->build_list_start($list);

	foreach my $item (@{ $list->{items} }) {
		$output .= $this->list_item($item);
	}

	$output .= $this->build_list_end($list);

	return $output;
}

sub build_list_item {
	my ($this, $li) = @_;
	return $this->_build_GENERIC("li", $li);
}

sub build_list_start {
	my ($this, $list) = @_;
	my %types = (
		OOF::LIST_UN() => "ul",
		OOF::LIST_OD() => "ol",
	);
	return $this->_start_GENERIC($types{$list->{type}}, $list);
}

sub build_list_end {
	my ($this, $list) = @_;
	my %types = (
		OOF::LIST_UN() => "ul",
		OOF::LIST_OD() => "ol",
	);
	return $this->_end_GENERIC($types{$list->{type}}, $list);
}

sub build_map {
	my ($this, $map) = @_;
	return $this->_build_GENERIC("map", $map);
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

sub build_strong {
	my ($this, $strong) = @_;
	return $this->_build_GENERIC("strong", $strong);
}

sub build_table {
	my ($this, $table) = @_;

	my $output = $this->build_table_start($table);

	foreach my $row (@{ $table->{rows} }) {
		$output .= $this->table_row(@$row);
	}

	$output .= $this->build_table_end($table);

	return $output;
}

sub build_table_start {
	my ($this, $table) = @_;

	my $colgroup = "";

	if (@{ $table->{cols} }) {
		$colgroup .= "<colgroup>";

		my ($key, $val);
		foreach my $col (@{ $table->{cols} }) {
			$colgroup .= "<col";
			while (($key, $val) = each %$col) {
				$colgroup .= qq! $key="$val"!;
			}
			$colgroup .= " />";
		}

		$colgroup .= "</colgroup>";
	}

	return $this->_start_GENERIC("table", $table) . $colgroup;
}

sub build_table_end {
	my ($this, $table) = @_;
	return $this->_end_GENERIC("table", $table);
}

sub build_table_row {
	my ($this, $tr) = @_;

	my $output = "<tr>";
	my $coltype;

	my ($key, $attrval, $val);
	foreach my $col (@{ $tr->{cols} }) {
		my %prefs;
		my $val = "";
		if (ref $col eq "HASH") {
			%prefs = %$col;
		} else {
			$val = $col;
		}
		if (exists $prefs{table_head}) {
			$coltype = "th";
			delete $prefs{table_head};
		} else {
			$coltype = "td";
		}

		$output .= "<$coltype";

		if ($prefs{value}) {
			if (ref $prefs{value} eq "ARRAY") {
				$val = join '', @{ $prefs{value} };
			} else {
				$val = $prefs{value};
			}
			delete $prefs{value};
		}

		while (($key, $attrval) = each %prefs) {
			$output .= qq! $key="$attrval"!;
		}

		$output .= ">$val</$coltype>";
	}

	$output .= "</tr>";

	return $output;
}

sub build_tt {
	my ($this, $tt) = @_;
	return $this->_build_GENERIC("tt", $tt);
}

# The deprecated (but still active) behavior is to implicitly call
# SUPER::AUTOLOAD(), so override this # behavior to disable this from
# happening.
#
# sub AUTOLOAD {
#	my ($this) = @_;
#	our $AUTOLOAD;
#	$this->{wasp}->throw("No such method; method: $AUTOLOAD");
# }

1;
