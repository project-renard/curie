use Renard::Curie::Setup;
package Renard::Curie::Container::App;
# ABSTRACT: A Bread::Board container for the application

use Moose;
use Bread::Board::Declare;

# Subcomponents
has menu_bar => (
	is => 'ro',
	isa => 'Renard::Curie::Component::MenuBar',
	infer => 1,
	lifecycle => 'Singleton',
);

has outline => (
	is => 'ro',
	isa => 'Renard::Curie::Component::Outline',
	infer => 1,
	lifecycle => 'Singleton',
);

has log_window => (
	is => 'ro',
	isa => 'Renard::Curie::Component::LogWindow',
	infer => 1,
	lifecycle => 'Singleton',
);

# Main component
has main_window => (
	is => 'ro',
	isa => 'Renard::Curie::Component::MainWindow',
	dependencies => [qw(app log_window outline menu_bar)],
	lifecycle => 'Singleton',
);

# App
has app => (
	is => 'ro',
	isa => 'Renard::Curie::App',
	infer => 1,
	lifecycle => 'Singleton',
);

method _test_current_view() {
	$self->main_window->page_document_component->view;
}

1;
