use Renard::Incunabula::Common::Setup;
package Renard::Curie::Document::Role::TextExtent;
# ABSTRACT: A role to provide information on text extents

use Moo::Role;

method get_bboxes( $text, $start, $end ) {
	my @bbox;
	for my $pos ($start..$end-1) {
		push @bbox, $text->get_tag_at($pos,'char')->{bbox};
	}

	\@bbox;
}

1;
