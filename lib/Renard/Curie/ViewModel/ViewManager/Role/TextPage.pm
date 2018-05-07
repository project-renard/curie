use Renard::Incunabula::Common::Setup;
package Renard::Curie::ViewModel::ViewManager::Role::TextPage;

use Moo::Role;

use Renard::Incunabula::Language::EN;
use Scalar::Util qw(refaddr);

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

	Renard::Incunabula::Language::EN::apply_sentence_offsets_to_blocks($txt);

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

1;
