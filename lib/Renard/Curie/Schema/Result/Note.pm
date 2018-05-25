use Modern::Perl;
package Renard::Curie::Schema::Result::Note;

use DBIx::Class::Candy
	-autotable => v1;

primary_column id => {
	data_type => 'integer',
	is_auto_increment => 1,
};

#    id              integer primary key,
#      -- epoch seconds of when the note was created
#    guid            text not null,
#      -- globally unique id, almost certainly used for syncing
#    mid             integer not null,
#      -- model id
#    mod             integer not null,
#      -- modification timestamp, epoch seconds
#    usn             integer not null,
#      -- update sequence number: for finding diffs when syncing.
#      --   See the description in the cards table for more info
#    tags            text not null,
#      -- space-separated string of tags.
#      --   includes space at the beginning and end, for LIKE "% tag %" queries
#    flds            text not null,
#      -- the values of the fields in this note. separated by 0x1f (31) character.
#    sfld            text not null,
#      -- sort field: used for quick sorting and duplicate check
#    csum            integer not null,
#      -- field checksum used for duplicate check.
#      --   integer representation of first 8 digits of sha1 hash of the first field
#    flags           integer not null,
#      -- unused
#    data            text not null
#      -- unused

1;
