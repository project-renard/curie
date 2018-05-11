package Renard::Curie::Schema::Result::PhraseCloze;

use Modern::Perl;
use DBIx::Class::Candy;

table 'phrase_cloze';

primary_column id => {
	data_type => 'integer',
	is_auto_increment => 1,
};

column document_id => {
	data_type => 'integer',
	is_nullable => 0,
};

column page => {
	data_type => 'integer',
	is_nullable => 0,
};

column text => {
	data_type => 'text',
	is_nullable => 0,
};

column offset_start => {
	data_type => 'integer',
	is_nullable => 0,
};

column offset_end => {
	data_type => 'integer',
	is_nullable => 0,
};

belongs_to 'document_id', 'Renard::Curie::Schema::Result::Document';

might_have 'pytextrank_cloze' => 'Renard::Curie::Schema::Result::PytextrankCloze', 'phrase_cloze_id';

1;
