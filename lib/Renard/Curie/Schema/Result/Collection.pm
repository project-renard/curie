use Modern::Perl;
package Renard::Curie::Schema::Result::Collection;

use DBIx::Class::Candy
	-autotable => v1;

primary_column id => {
	data_type => 'integer',
	is_auto_increment => 1,
};

column conf => {
	data_type => 'text',
};

1;
