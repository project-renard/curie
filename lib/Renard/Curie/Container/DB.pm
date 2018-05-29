use Renard::Incunabula::Common::Setup;
package Renard::Curie::Container::DB;
# ABSTRACT: A Bread::Board container for the DB schema

use Moose;
use Bread::Board::Declare;

has [ qw(dsn user password) ] => (
	is => 'ro',
	isa => 'Str',
	lifecycle => 'Singleton',
);

has attr => (
	is => 'ro',
	isa => 'HashRef',
	lifecycle => 'Singleton',
);

has schema => (
	is => 'ro',
	isa => 'Renard::Curie::Schema',
	dependencies => [qw(dsn user password attr)],
	lifecycle => 'Singleton',
	block => method() {
		Renard::Curie::Schema->connect(
			$self->param('dsn'),
			$self->param('user'),
			$self->param('password'),
			$self->param('attr'),
		);
	},
);

1;
