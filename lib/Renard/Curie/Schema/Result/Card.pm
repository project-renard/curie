use Modern::Perl;
package Renard::Curie::Schema::Result::Card;

use DBIx::Class::Candy
	-autotable => v1;

#    id              integer primary key,
#      -- the epoch milliseconds of when the card was created
primary_column id => {
	data_type => 'integer',
	is_auto_increment => 1,
};

#    nid             integer not null,--
#      -- notes.id
column nid => {
	data_type => 'integer',
	is_nullable => 0,
};

#    ord             integer not null,
#      -- ordinal : identifies which of the card templates it corresponds to
#      --   valid values are from 0 to num templates - 1
column ord => {
	data_type => 'integer',
	is_nullable => 0,
};

#    mod             integer not null,
#      -- modificaton time as epoch seconds
column mod => {
	data_type => 'integer',
	is_nullable => 0,
};

#    type            integer not null,
#      -- 0=new, 1=learning, 2=due, 3=filtered
column type => {
	data_type => 'integer',
	is_nullable => 0,
};

#    queue           integer not null,
#      -- -3=sched buried, -2=user buried, -1=suspended,
#      -- 0=new, 1=learning, 2=due (as for type)
#      -- 3=in learning, next rev in at least a day after the previous review
column queue => {
	data_type => 'integer',
	is_nullable => 0,
};

#    due             integer not null,
#     -- Due is used differently for different card types:
#     --   new: note id or random int
#     --   due: integer day, relative to the collection's creation time
#     --   learning: integer timestamp
column due => {
	data_type => 'integer',
	is_nullable => 0,
};

#    ivl             integer not null,
#      -- interval (used in SRS algorithm). Negative = seconds, positive = days
column ivl => {
	data_type => 'integer',
	is_nullable => 0,
};

#    factor          integer not null,
#      -- factor (used in SRS algorithm)
column factor => {
	data_type => 'integer',
	is_nullable => 0,
};

#    reps            integer not null,
#      -- number of reviews
column reps => {
	data_type => 'integer',
	is_nullable => 0,
};

#    lapses          integer not null,
#      -- the number of times the card went from a "was answered correctly"
#      --   to "was answered incorrectly" state
column lapses => {
	data_type => 'integer',
	is_nullable => 0,
};

#    left            integer not null,
#      -- reps left till graduation
column left => {
	data_type => 'integer',
	is_nullable => 0,
};

1;
