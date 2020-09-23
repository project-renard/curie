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
	return unless $self->view_manager->tts_playing;
	my @top_left = (0,0);
	if( @{ $self->view_manager->current_text_page } ) {
		my $sentence = $self->view_manager->current_text_page->[
			$self->view_manager->current_sentence_number
		];

		my @bboxes;
		my $page_number = $self->view->page_number;
		my ($page, $view) = $self->drawing_area->_get_page_view_for_page_number($page_number);
		return unless $view;

		my @extents = ( $sentence->{extent}->start,
			$sentence->{extent}->end, );

		push @bboxes, @{
			$self->drawing_area->_get_bboxes_for_page_extents(
				$page, $view, \@extents )
		};

		for my $bounds (@bboxes) {
			$self->drawing_area->_draw_bounds_as_rectangle($cr, $bounds);
			$cr->set_source_rgba(1, 0, 0, 0.2);
			$cr->fill;
		}
	}
}

1;
