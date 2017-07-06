use Renard::Curie::Setup;
package Renard::Curie::Model::View::Grid;
# ABSTRACT: A view model for grid-based views

use Moo;

use Renard::Curie::Types qw(InstanceOf ArrayRef SizeRequest);
use POSIX qw(ceil);
use List::AllUtils qw(part);

use MooX::Struct
	GridScheme => [ qw( rows columns pages) ]
;

use Renard::Curie::Model::View;
use Glib::Object::Subclass
	'Glib::Object',
	signals => { 'view-changed' => {} },
	;
extends 'Renard::Curie::Model::View';

use Renard::Curie::Model::View::Grid::Subview;

classmethod FOREIGNBUILDARGS(@) {
	return ();
}

=attr view_options

A L<Renard::Curie::Model::ViewOptions> that defines how the grid layout
will be constructed.

=cut
has view_options => (
	is => 'ro',
	required => 1,
	isa => InstanceOf['Renard::Curie::Model::ViewOptions'],
);

has _grid_schemes => (
	is => 'lazy', # _build__grid_schemes
	isa => ArrayRef, # ArrayRef[GridScheme]
);

method draw_page(
	(InstanceOf['Gtk3::DrawingArea']) $widget,
	(InstanceOf['Cairo::Context']) $cr
) {
	# uncoverable subroutine
	my $p =  $widget->get_parent;
	my $v = $p->get_vadjustment;

	my $view_y_min = $v->get_value;
	my $view_y_max = $v->get_value + $v->get_page_size;

	my $subview = $self->_current_subview;

	$self->_widget_dims([
		$widget->get_allocated_width,
		$widget->get_allocated_height,
	]);
	$subview->_clear_page_info;
	my $page_xy = $subview->_page_info->{page_xy};
	my $zoom_level = $self->zoom_level;
	for my $page (@$page_xy) {
		next if $page->{bbox}[3] < $view_y_min
			|| $page->{bbox}[1] > $view_y_max;

		my $rp = $self->document->get_rendered_page(
			page_number => $page->{pageno},
			zoom_level => $zoom_level,
		);

		my $img = $rp->cairo_image_surface;

		$cr->set_source_surface($img,
			$page->{bbox}[0],
			$page->{bbox}[1]);

		$cr->paint;
	}
}

method get_size_request() :ReturnType( list => SizeRequest) {
	return $self->_current_subview->get_size_request;
}

method _current_subview() {
	$self->_subviews->[ $self->_subview_idx ];
}

has _widget_dims => (
	is => 'rw',
	default => sub { [0, 0] },
);


method _build__grid_schemes() {
	my $go_r = $self->view_options->grid_options->rows;
	my $go_c = $self->view_options->grid_options->columns;
	my @page_numbers = ( $self->document->first_page_number .. $self->document->last_page_number);

	my ($g_r, $g_c);
	if( defined $go_r && defined $go_c ) {
		($g_r, $g_c) = ($go_r, $go_c);
	} elsif( defined $go_r && ! defined $go_c ) {
		$g_r = $go_r;
		$g_c = ceil($self->document->number_of_pages / $go_r);
	} elsif( ! defined $go_r && defined $go_c ) {
		$g_r = ceil($self->document->number_of_pages / $go_c);
		$g_c = $go_c;
	} else {
		Renard::Curie::Error::Programmer::Logic->new(
			msg => 'GridOption improperly constructed: both row and columns undef',
		);
	}

	my $num_pages_per_view = $g_r * $g_c;
	my $num_views = ceil( $self->document->number_of_pages / $num_pages_per_view );
	my @grid_pages = part { int( $_ / $num_pages_per_view ) } 0 .. @page_numbers - 1;

	my @grid_collection = map {
		my @this_grid_page_idx = @$_;
		my @this_grid_pages = map {
			$page_numbers[$_]
		} @this_grid_page_idx;
		GridScheme->new( rows => $g_r, columns => $g_c, pages => \@this_grid_pages );
	} @grid_pages;

	return \@grid_collection;
}

method _build__subviews() {
	[
		map {
			Renard::Curie::Model::View::Grid::Subview->new(
				_grid_view => $self,
				_grid_scheme => $_,
			);
		} @{ $self->_grid_schemes }
	];
}

method _trigger__subview_idx() {
	$self->_clear_subviews;
	$self->signal_emit( 'view-changed' );
}

method _trigger_zoom_level($new_zoom_level) {
	$self->_clear_subviews;
	$self->signal_emit( 'view-changed' );
}

method page_number() {
	42;
}

with qw(
	Renard::Curie::Model::View::Role::ForDocument
	Renard::Curie::Model::View::Role::Renderable
	Renard::Curie::Model::View::Role::Zoomable
	Renard::Curie::Model::View::Role::SubviewPageable
);

1;
