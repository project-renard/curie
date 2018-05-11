package Renard::Curie::Schema::Candy;

use Modern::Perl;

use base 'DBIx::Class::Candy';

sub base { $_[1] || 'Renard::Curie::Schema' }
sub autotable { 1 }

1;
