use Modern::Perl;
package Renard::Curie::Schema::Result::Note;

use DBIx::Class::Candy
	-autotable => v1;

#    id              integer primary key,
#      -- epoch seconds of when the note was created
primary_column id => {
	data_type => 'integer',
	is_auto_increment => 1,
};

#    mod             integer not null,
#      -- modification timestamp, epoch seconds
column mod => {
	data_type => 'integer',
	is_nullable => 0,
};

#    tags            text not null,
#      -- space-separated string of tags.
#      --   includes space at the beginning and end, for LIKE "% tag %" queries
column tags => {
	data_type => 'text',
	is_nullable => 0,
};

1;
