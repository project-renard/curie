use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::PageDrawingArea::Role::HighlightCurrentSentence;
# ABSTRACT: Drawing over the current sentence to highlight it

use Moo::Role;

use Renard::Incunabula::Common::Types qw(InstanceOf);

after on_draw_page_cb => method( (InstanceOf['Cairo::Context']) $cr ) {
	$self->on_draw_page_cb_highlight( $cr );
};

=method on_draw_page_cb_highlight

  method on_draw_page_cb_highlight( (InstanceOf['Cairo::Context']) $cr )

Highlights the current sentence on the page.

=cut
method on_draw_page_cb_highlight( (InstanceOf['Cairo::Context']) $cr ) {
	my @top_left = (0,0);
	if( @{ $self->view_manager->current_text_page } ) {
		my $sentence = $self->view_manager->current_text_page->[
			$self->view_manager->current_sentence_number
		];
		for my $bbox_str ( @{ $sentence->{bbox} } ) {
			my $bbox = [ split ' ', $bbox_str ];
			my $z_bbox = [ map {
				$_ * $self->view_manager
					->view_options
					->zoom_options
					->zoom_level
			} @$bbox ];
			$cr->rectangle(
				$top_left[0] + $z_bbox->[0],
				$top_left[1] + $z_bbox->[1],
				$z_bbox->[2] - $z_bbox->[0],
				$z_bbox->[3] - $z_bbox->[1],
			);
			$cr->set_source_rgba(1, 0, 0, 0.2);
			$cr->fill;
		}
	}
}

1;
