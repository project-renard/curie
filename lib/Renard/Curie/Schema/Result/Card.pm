use Modern::Perl;
package Renard::Curie::Schema::Result::Card;

use DBIx::Class::Candy
	-autotable => v1;

primary_column id => {
	data_type => 'integer',
	is_auto_increment => 1,
};

#    id              integer primary key,
#      -- the epoch milliseconds of when the card was created
#    nid             integer not null,--
#      -- notes.id
#    did             integer not null,
#      -- deck id (available in col table)
#    ord             integer not null,
#      -- ordinal : identifies which of the card templates it corresponds to
#      --   valid values are from 0 to num templates - 1
#    mod             integer not null,
#      -- modificaton time as epoch seconds
#    usn             integer not null,
#      -- update sequence number : used to figure out diffs when syncing.
#      --   value of -1 indicates changes that need to be pushed to server.
#      --   usn < server usn indicates changes that need to be pulled from server.
#    type            integer not null,
#      -- 0=new, 1=learning, 2=due, 3=filtered
#    queue           integer not null,
#      -- -3=sched buried, -2=user buried, -1=suspended,
#      -- 0=new, 1=learning, 2=due (as for type)
#      -- 3=in learning, next rev in at least a day after the previous review
#    due             integer not null,
#     -- Due is used differently for different card types:
#     --   new: note id or random int
#     --   due: integer day, relative to the collection's creation time
#     --   learning: integer timestamp
#    ivl             integer not null,
#      -- interval (used in SRS algorithm). Negative = seconds, positive = days
#    factor          integer not null,
#      -- factor (used in SRS algorithm)
#    reps            integer not null,
#      -- number of reviews
#    lapses          integer not null,
#      -- the number of times the card went from a "was answered correctly"
#      --   to "was answered incorrectly" state
#    left            integer not null,
#      -- reps left till graduation
#    odue            integer not null,
#      -- original due: only used when the card is currently in filtered deck
#    odid            integer not null,
#      -- original did: only used when the card is currently in filtered deck
#    flags           integer not null,
#      -- currently unused
#    data            text not null
#      -- currently unused

1;
