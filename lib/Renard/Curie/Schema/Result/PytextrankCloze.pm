package Renard::Curie::Schema::Result::PytextrankCloze;
# ABSTRACT: Table for cloze phrases from Pytextrank

use Modern::Perl;
use DBIx::Class::Candy;

table 'pytextrank_cloze';

primary_column phrase_cloze_id => {
	data_type => 'integer',
};

primary_column pytextrank_data_id => {
	data_type => 'integer',
};



belongs_to 'phrase_cloze_id', 'Renard::Curie::Schema::Result::PhraseCloze';
belongs_to 'pytextrank_data_id', 'Renard::Curie::Schema::Result::PytextrankData';

1;
