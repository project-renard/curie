use Renard::Incunabula::Common::Setup;
package Renard::Curie::ViewModel::ViewManager;
# ABSTRACT: Manages the currently open views

use Moo;
use Renard::Incunabula::Common::Types qw(InstanceOf Path FileUri PositiveInt);
use Renard::Incunabula::Document::Types qw(DocumentModel ZoomLevel);
use Renard::Incunabula::Format::PDF::Document;

use Renard::Curie::Model::ViewOptions;
use Renard::Curie::Model::ViewOptions::Grid;
use Renard::Curie::Model::ViewOptions::Zoom::Percentage;
use Renard::Curie::Model::View::Grid;

use Glib::Object::Subclass
	'Glib::Object',
	signals => {
		'document-changed' => {
			param_types => [
				'Glib::Scalar', # DocumentModel
			]
		},
		'update-view' => {
			param_types => [
				'Glib::Scalar', # View
			]
		},
	},
	;


has number_of_columns => (
	is => 'rw',
	isa => PositiveInt,
	default => sub { 1 },
	trigger => 1, # _trigger_number_of_columns
);

has view_options => (
	is => 'rw',
	lazy => 1,
	builder => sub {
		my $view_options = Renard::Curie::Model::ViewOptions->new;
	},
	trigger => 1, # _trigger_view_options
	clearer => 1, # clear_view_options
);

has current_document => (
	is => 'rw',
	isa => DocumentModel,
	trigger => 1, # _trigger_current_document
);

has current_view => (
	is => 'rw',
	isa => InstanceOf['Renard::Curie::Model::View'],
	trigger => 1, # _trigger_current_view
);

method _trigger_current_view($view) {
	$self->signal_emit( 'update-view' => $view );
}

method _trigger_number_of_columns($new_number_of_columns) {
	my $grid_options = $self->view_options->grid_options->cset( columns => $new_number_of_columns );
	my $view_options = $self->view_options->cset( grid_options => $grid_options );
	$self->view_options( $view_options );
}

method _trigger_current_document( (DocumentModel) $doc ) {
	$self->clear_view_options;
	$self->current_view(
		Renard::Curie::Model::View::Grid->new(
			view_options => $self->view_options,
			document => $doc,
		)
	);

	$self->signal_emit( 'document-changed' => $doc );
}

method _trigger_view_options( $new_view_options ) {
	my $page_number = $self->current_view->page_number;
	my $view = Renard::Curie::Model::View::Grid->new(
		document => $self->current_document,
		view_options => $new_view_options,
		( page_number => $page_number ) x !!( defined $page_number ),
	);
	$self->current_view( $view );

	# TODO remove this part and have everything come from the zoom options
	my $zoom_level = $new_view_options->zoom_options->zoom_level;
	$self->current_view->zoom_level( $zoom_level );
}

=method open_pdf_document

  method open_pdf_document( (Path->coercibles) $pdf_filename )

Opens a PDF file stored on the disk.

=cut
method open_pdf_document( (Path->coercibles) $pdf_filename ) {
	$pdf_filename = Path->coerce( $pdf_filename );
	if( not -f $pdf_filename ) {
		Renard::Incunabula::Common::Error::IO::FileNotFound
			->throw("PDF filename does not exist: $pdf_filename");
	}

	$self->current_document(
		Renard::Incunabula::Format::PDF::Document->new(
			filename => $pdf_filename,
		)
	);
}

=method open_document_as_file_uri

  method open_document_as_file_uri( (FileUri) $uri )

Takes a file in the form of a C<FileUri> and opens the file.

=cut
method open_document_as_file_uri( (FileUri) $uri ) {
	$self->open_pdf_document( $uri->file );
}

=method set_view_to_continuous_page

  method set_view_to_continuous_page()

Sets the L</current_view> to L<Renard::Curie::Model::View::Grid> with C<rows>
C<GridOptions> set to C<undef>.

=cut
method set_view_to_continuous_page() {
	my $grid_options = $self->view_options->grid_options->cset( rows => undef );
	my $view_options = $self->view_options->cset( grid_options => $grid_options );
	$self->view_options( $view_options );
}

=method set_view_to_single_page

  method set_view_to_single_page()

Sets the L</current_view> to L<Renard::Curie::Model::View::Grid> with C<rows>
C<GridOptions> set to C<1>.

=cut
method set_view_to_single_page() {
	my $grid_options = $self->view_options->grid_options->cset( rows => 1 );
	my $view_options = $self->view_options->cset( grid_options => $grid_options );
	$self->view_options( $view_options );
}

=method set_zoom_level

  method set_zoom_level( (ZoomLevel) $zoom_level )

Sets the L</current_view> to L<Renard::Curie::Model::View::Grid> with C<zoom_level>
of L<Renard::Curie::Model::ViewOptions::Zoom::Percentage> set to C<$zoom_level>.

=cut
method set_zoom_level( (ZoomLevel) $zoom_level ) {
	my $zoom_option = Renard::Curie::Model::ViewOptions::Zoom::Percentage->new(
		zoom_level => $zoom_level,
	);
	my $view_options = $self->view_options->cset(
		zoom_options => $zoom_option
	);
	$self->view_options( $view_options );
}

method current_text_page() {
	return [] unless $self->current_document->can('get_textual_page');

	my $page_number = $self->current_view->page_number;
	my $txt = $self->current_document->get_textual_page($page_number);

	use Renard::Incunabula::Language::EN;
	use Scalar::Util qw(refaddr);
	Renard::Incunabula::Language::EN::apply_sentence_offsets_to_blocks($txt);

	my @sentence_spans = ();
	$txt->iter_extents(sub {
		my ($extent, $tag_name, $tag_value) = @_;
		my $data = {
			sentence => $extent->substr,
			extent => $extent,
		};
		$data->{sentence}->iter_extents( sub {
			my ($extent, $tag_name, $tag_value) = @_;
			push @{  $data->{spans} }, $tag_value;
		}, only => ['font']);
		push @sentence_spans, $data;
	}, only => ['sentence'] );

	for my $sentence (@sentence_spans) {
		my $extent = $sentence->{extent};
		$sentence->{first_char} = $txt->get_tag_at( $extent->start, 'char' );
		$sentence->{last_char} = $txt->get_tag_at( $extent->end-1, 'char' );
		my @spans = @{ $sentence->{spans} };
		my @bb = ();
		if( @spans == 1 ) {
			# must be in the same span
			my $first_span = $spans[0];
			my $in_range = 0;
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
		} else {
			for my $span (@spans) {
				push @bb, $span->{bbox};
			}
			if( $sentence->{first_char} != $spans[0]{char}[0] ) {
				shift @bb;
				for my $char (reverse @{$spans[0]{char}}) {
					unshift @bb, $char->{bbox};
					last if refaddr $sentence->{first_char} == refaddr $char;
				}
			}
			if( $sentence->{last_char} != $spans[-1]{char}[-1] ) {
				pop @bb;
				for my $char (@{$spans[-1]{char}}) {
					push @bb, $char->{bbox};
					last if refaddr $sentence->{last_char} == refaddr $char;
				}
			}
		}
		$sentence->{bbox} = \@bb;
	}

	\@sentence_spans;
}

1;
