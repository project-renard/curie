use Renard::Incunabula::Common::Setup;
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

has tts_window => (
	is => 'ro',
	isa => 'Renard::Curie::Component::TTSWindow',
	infer => 1,
	lifecycle => 'Singleton',
);

has action_notebook_window => (
	is => 'ro',
	isa => 'Renard::Curie::Component::ActionNotebookWindow',
	infer => 1,
	lifecycle => 'Singleton',
);

# Main component
has main_window => (
	is => 'ro',
	isa => 'Renard::Curie::Component::MainWindow',
	dependencies => [qw(log_window outline menu_bar view_manager tts_window action_notebook_window)],
	lifecycle => 'Singleton',
);

# Model

has database => (
	traits => [ 'Container' ],
	is => 'ro',
	isa => 'Renard::Curie::Container::DB',
	default => sub {
		my $db_ctr = Renard::Curie::Container::DB->new(
			dsn => 'dbi:SQLite:dbname=:memory:',
			user => '',
			password => '',
			attr => +{ sqlite_unicode => 1},
		);
		$db_ctr->schema->deploy( { add_drop_table => 1 } );

		$db_ctr;
	},
);

has view_manager => (
	is => 'ro',
	isa => 'Renard::Curie::ViewModel::ViewManager',
	dependencies => [qw(database/schema)],
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
	$self->view_manager->current_view;
}

1;
