package Renard::Curie::Schema;

use Modern::Perl;

use Moose;

extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

1;
