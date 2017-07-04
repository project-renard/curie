use Renard::Curie::Setup;
package Renard::Curie::Model::View::Grid;
# ABSTRACT: A view model for grid-based views

use Moo;

use Renard::Curie::Types qw(InstanceOf ArrayRef);
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
	[ (1) x scalar @{ $self->_grid_schemes } ],
}

method _trigger__subview_idx() {
	...
}


with qw(
	Renard::Curie::Model::View::Role::ForDocument
	Renard::Curie::Model::View::Role::Renderable
	Renard::Curie::Model::View::Role::SubviewPageable
);

1;
