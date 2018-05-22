use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::PageDrawingArea::Role::HighlightCurrentPhraseCloze;
# ABSTRACT: A role to highlight the phrases on the page

use Moo::Role;

use Renard::Incunabula::Common::Types qw(InstanceOf);
use Renard::Taffeta::Color::RGB24;

after on_draw_page_cb => method( (InstanceOf['Cairo::Context']) $cr ) {
	$self->on_draw_page_cb_highlight_phrases( $cr );
};

=method on_draw_page_cb_highlight_phrases

  method on_draw_page_cb_highlight_phrases( (InstanceOf['Cairo::Context']) $cr )

Highlights the current phrases on the page.

=cut
method on_draw_page_cb_highlight_phrases( (InstanceOf['Cairo::Context']) $cr ) {
	return unless $self->view_manager->current_document->can('get_textual_page');
	return unless $self->view_manager->current_phrase_schema_result;

	my $page_number = $self->view_manager->current_view->page_number;
	my $text = $self->view_manager->current_document->get_textual_page($page_number);

	my $phrases = $self->view_manager->phrases_on_current_page;

	while( my $phrase = $phrases->next ) {
		my $is_phrase_the_current_phrase =
			$self->view_manager->current_phrase_schema_result->id
				== $phrase->id;
		$self->draw_bbox_for_phrase(
			$cr,
			$text,
			$phrase,
			$is_phrase_the_current_phrase
		) if $is_phrase_the_current_phrase;
	}
}

method get_bbox_args( $top_left, $z_bbox ) {
	return (
		$top_left->[0] + $z_bbox->[0],
		$top_left->[1] + $z_bbox->[1],
		$z_bbox->[2]   - $z_bbox->[0],
		$z_bbox->[3]   - $z_bbox->[1],
	);
}

method draw_bbox_for_text_offset( $cr, $text, $start, $end, $color ) {
	my @top_left = (0,0);

	my $bboxes = $self->view_manager->current_document->get_bboxes(
		$text, $start, $end,
	);

	my $stroke_color = Renard::Taffeta::Color::RGB24->new(
		value => 0x2D2D2D
	);

	my @processed_bboxes = map {
		my $bbox_str = $_;
		my $bbox = [ split ' ', $bbox_str ];
		my $z_bbox = [ map {
			$_ * $self->view_manager
				->view_options
				->zoom_options
				->zoom_level
		} @$bbox ];

		$z_bbox;
	} @$bboxes;

	for my $z_bbox ( @processed_bboxes ) {
		$cr->rectangle(
			$self->get_bbox_args( \@top_left, $z_bbox )
		);
		$cr->set_source_rgba($color->rgb_float_triple, 1);
		$cr->fill;
	}
	my $first_bbox = $processed_bboxes[0];
	my $last_bbox = $processed_bboxes[-1];

	$cr->rectangle(
		$top_left[0] + $first_bbox->[0],
		$top_left[1] + $first_bbox->[1],
		$last_bbox->[2] - $first_bbox->[0],
		$last_bbox->[3] - $first_bbox->[1],
	);
	$cr->set_source_rgba($stroke_color->rgb_float_triple, 1);
	$cr->set_line_width(2);
	$cr->stroke;

}

method draw_bbox_for_phrase( (InstanceOf['Cairo::Context']) $cr, $text, $phrase, $is_current ) {
	my $current_phrase_color = Renard::Taffeta::Color::RGB24->new(
		value => 0xFFEBA2
	);
	my $covered_phrase_color = Renard::Taffeta::Color::RGB24->new(
		value => 0xFF7E7E
	);

	$self->draw_bbox_for_text_offset( $cr,
		$text,
		$phrase->offset_start, $phrase->offset_end,
		$is_current ? $current_phrase_color : $covered_phrase_color,
	);
}

1;
