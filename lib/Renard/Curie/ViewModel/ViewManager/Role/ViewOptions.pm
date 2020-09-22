use Renard::Incunabula::Common::Setup;
package Renard::Curie::ViewModel::ViewManager::Role::ViewOptions;
# ABSTRACT: A role for the view options

use Moo::Role;

use Renard::Incunabula::Common::Types qw(InstanceOf);

use Renard::Curie::Model::ViewOptions;
use Renard::Curie::Model::View::Grid;

has current_view => (
	is => 'rw',
	isa => InstanceOf['Renard::Curie::Model::View'],
	trigger => 1, # _trigger_current_view
);

method _trigger_current_view($view) {
	$view->signal_connect( 'view-changed', sub {
		$self->signal_emit( 'update-view' => $self->current_view );
	});
	$self->signal_emit( 'update-view' => $view );
}

has view_options => (
	is => 'rw',
	lazy => 1,
	builder => sub {
		my $view_options = Renard::Curie::Model::ViewOptions->new;
	},
	trigger => 1, # _trigger_view_options
	clearer => 1, # clear_view_options
);


method _trigger_view_options( $new_view_options ) {
	my $page_number = $self->current_view->page_number;
	my $view = Renard::Curie::Model::View::Grid->new(
		document => $self->current_document,
		view_options => $new_view_options,
	);
	$self->current_view( $view );

	if( defined $page_number ) {
		$view->set_page_number_with_scroll( $page_number );
	}
}

1;
