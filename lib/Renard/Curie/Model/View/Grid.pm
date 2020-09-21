use Renard::Incunabula::Common::Setup;
package Renard::Curie::Model::View::Grid;
# ABSTRACT: A view model for grid-based views

use Moo;

use Renard::Incunabula::Common::Types qw(InstanceOf ArrayRef);
use Renard::API::Gtk3::Types qw(SizeRequest);
use POSIX qw(ceil);
use List::AllUtils qw(part first);
use Glib qw(TRUE FALSE);
use Test::Deep::NoTest;

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

=classmethod FOREIGNBUILDARGS

  classmethod FOREIGNBUILDARGS(@)

Initialises the L<Glib::Object> super-class.

=cut
classmethod FOREIGNBUILDARGS(@) {
	return ();
}

=attr view_options

A L<Renard::Curie::Model::ViewOptions> that defines how the grid layout
will be constructed.

Predicate: L<has_view_options>

=method has_view_options

A predicate for the C<view_options> attribute.

=cut
has view_options => (
	is => 'ro',
	required => 1,
	predicate => 1, # has_view_options
	isa => InstanceOf['Renard::Curie::Model::ViewOptions'],
);

has _grid_schemes => (
	is => 'lazy', # _build__grid_schemes
	isa => ArrayRef, # ArrayRef[GridScheme]
);

method _current_subview() {
	$self->_subviews->[ $self->_subview_idx ];
}

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
		Renard::Incunabula::Common::Error::Programmer::Logic->new(
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
	$self->signal_emit( 'view-changed' );
}

method _update_subview_idx() {
	my $page_number = $self->page_number;
	my $subview_has_page = !! grep {
		$_ == $page_number
	} @{ $self->_grid_schemes->[$self->_subview_idx]->pages };
	if( ! $subview_has_page ) {
		my $idx = first {
			my $idx = $_;
			my $subview_pages = $self->_grid_schemes->[$idx]->pages;
			defined first { $_ == $page_number } @$subview_pages;
		} 0 .. @{ $self->_grid_schemes } - 1;
		$self->_subview_idx( $idx );
	}
}

method _trigger_page_number($page_number) {
	$self->_update_subview_idx;
	$self->signal_emit( 'view-changed' );
}

with qw(
	Renard::Curie::Model::View::Role::ForDocument
	Renard::Curie::Model::View::Role::Pageable
	Renard::Curie::Model::View::Role::SubviewPageable
);

1;
