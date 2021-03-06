use Renard::Incunabula::Common::Setup;
package Renard::Curie::ViewModel::ViewManager::Role::TTS;

use Moo::Role;

use Renard::Block::NLP;
use Scalar::Util qw(refaddr);

use Renard::Incunabula::Common::Types qw(Bool PositiveOrZeroInt);

=attr tts_playing

A C<Bool> that indicates if the TTS is playing or not.

=cut
has tts_playing => (
	is => 'rw',
	isa => Bool,
	default => sub { 0 },
);

=attr current_sentence_number

Stores the current sentence number index (0-based): C<PositiveOrZeroInt>.

=cut
has current_sentence_number => (
	is => 'rw',
	isa => PositiveOrZeroInt,
	trigger => 1, # _trigger_current_sentence_number
	default => 0,
);

method _trigger_current_sentence_number($new_current_sentence_number) {
	$self->signal_emit( 'update-view' => $self->current_view );
}

=method current_text_page

  method current_text_page()

Returns a C<HashRef> of sentences on the page.

Keys:

=for :list
* C<sentence>: C<String::Tagged> of the sentence substring
* C<bbox>: C<ArrayRef> of bounding boxes
* C<extent>: extent
* C<spans>: C<ArrayRef> of font spans
* C<first_char>: first character information
* C<last_char>: last character information


=cut
method current_text_page() {
	return [] unless $self->current_document->can('get_textual_page');

	my $page_number = $self->current_view->page_number;
	my $txt = $self->current_document->get_textual_page($page_number);

	Renard::Block::NLP::apply_sentence_offsets_to_blocks($txt);

	my @sentence_spans = ();
	$txt->iter_extents(sub {
		my ($extent, $tag_name, $tag_value) = @_;
		my $data = {
			sentence => $extent->substr,
			extent => $extent,
		};

		my $start = $extent->start;
		my $end = $extent->end;
		my $last_span = {};
		for my $pos ($start..$end-1) {
			my $value = $txt->get_tag_at($pos,'font');
			if( defined $value && refaddr $last_span != refaddr $value ) {
				$last_span = $value;
				push @{ $data->{spans} }, $value;
			}
		}

		push @sentence_spans, $data;
	}, only => ['sentence'] );

	for my $sentence (@sentence_spans) {
		my $extent = $sentence->{extent};
		$sentence->{first_char} = $txt->get_tag_at( $extent->start, 'char' );
		$sentence->{last_char} = $txt->get_tag_at( $extent->end-1, 'char' );
		my @spans = @{ $sentence->{spans} };
		my @bb = ();
		my $in_range = 0;
		for my $first_span ( @spans ) {
			for my $c (@{ $first_span->{char} }) {
				if( refaddr $c == refaddr $sentence->{first_char} ) {
					$in_range = 1;
				}

				push @bb, $c->{bbox} if $in_range;

				if( refaddr $c == refaddr $sentence->{last_char} ) {
					$in_range = 0;
					last;
				}
			}
		}

		$sentence->{bbox} = \@bb;
	}

	\@sentence_spans;
}

=method num_of_sentences_on_page

  method num_of_sentences_on_page()

Retrieves the number of sentences on the page.

=cut
method num_of_sentences_on_page() {
	my $text = $self->current_text_page;
	return @{ $text };
}

=method choose_previous_sentence

  method choose_previous_sentence()

Move to the previous sentence or the last sentence on the previous page.

=cut
method choose_previous_sentence() {
	my $v = $self->current_view;
	my $vm = $self;
	if( $vm->current_sentence_number > 0 ) {
		$vm->current_sentence_number( $vm->current_sentence_number - 1 );
	} elsif( $v->can_move_to_previous_page ) {
		$v->set_current_page_back;
		$vm->current_sentence_number(
			$self->num_of_sentences_on_page - 1
		);
	}
}

=method choose_next_sentence

  method choose_next_sentence()

Move to the next sentence on this page or to the first sentence on the next
page.

=cut
method choose_next_sentence() {
	my $v = $self->current_view;
	my $vm = $self;
	if( $vm->current_sentence_number < $self->num_of_sentences_on_page - 1 ) {
		$vm->current_sentence_number( $vm->current_sentence_number + 1 );
	} elsif( $v->can_move_to_next_page ) {
		$v->set_current_page_forward;
		$vm->current_sentence_number(0);
	} else {
		$self->tts_playing(0);
	}
}


1;
