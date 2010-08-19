# $Id$

sub list {
	my ($this, $type, @data) = @_;
	my $out = $this->list_start($type);
	$out .= $this->list_item($_) foreach @data;
	$out .= $this->list_end($type);

	return $out;
}

sub list_start;
sub list_end;
sub list_item;

0;
