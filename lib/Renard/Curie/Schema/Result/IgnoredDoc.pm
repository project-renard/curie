package Renard::Curie::Schema::Result::IgnoredDoc;
# ABSTRACT: Table for if the document should be ignored

use Modern::Perl;
use DBIx::Class::Candy
	-autotable => v1,
	-components => [ qw/InflateColumn::Boolean/ ]
	;

primary_column id => {
	data_type => 'integer',
	is_auto_increment => 1,
};

column document_id => {
	data_type => 'integer',
	is_nullable => 0,
};

column ignored => {
	# Boolean
	data_type => 'int',
	is_boolean => 1,
	is_nullable => 0,
};

belongs_to 'document_id', 'Renard::Curie::Schema::Result::Document';

1;
