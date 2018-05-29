use Renard::Incunabula::Common::Setup;
package Renard::Curie::Container::DBdefault;

use Moose;
extends qw(Renard::Curie::Container::DB);

use Path::Tiny;

has db_path => (
	is => 'ro',
	block => sub {
		my $sqlite_db = path('~/sw_projects/wiki/medicine/db/curie-cards.db');
		$sqlite_db->parent->mkpath;

		$sqlite_db;
	},
);

has dsn => (
	is => 'ro',
	dependencies => [qw(db_path)],
	block => sub {
		my $s = shift;

		my $sqlite_db = $s->param('db_path');
		return "dbi:SQLite:${sqlite_db}";
	},
);

has [qw(user password)] => (
	is => 'ro',
	value => '',
);

has attr => (
	is => 'ro',
	block => sub {
		return +{ sqlite_unicode => 1};
	}
);

method prepare_db() {
	if( ! -f $self->db_path ) {
		$self->schema->deploy( { add_drop_table => 1 } );
	}
}

1;
