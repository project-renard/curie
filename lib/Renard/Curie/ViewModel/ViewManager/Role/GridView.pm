use Renard::Incunabula::Common::Setup;
package Renard::Curie::ViewModel::ViewManager::Role::GridView;
# ABSTRACT: A role for the grid view

use Moo::Role;
use Renard::Incunabula::Common::Types qw(PositiveInt);

has number_of_columns => (
	is => 'rw',
	isa => PositiveInt,
	default => sub { 1 },
	trigger => 1, # _trigger_number_of_columns
);

method _trigger_number_of_columns($new_number_of_columns) {
	my $grid_options = $self->view_options->grid_options->cset( columns => $new_number_of_columns );
	my $view_options = $self->view_options->cset( grid_options => $grid_options );
	$self->view_options( $view_options );
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

1;
