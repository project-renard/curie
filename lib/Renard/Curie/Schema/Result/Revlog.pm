use Modern::Perl;
package Renard::Curie::Schema::Result::Revlog;

use DBIx::Class::Candy
	-autotable => v1;

#    id              integer primary key,
#       -- epoch-milliseconds timestamp of when you did the review
primary_column id => {
	data_type => 'integer',
};

#    cid             integer not null,
#       -- cards.id
column cid => {
	data_type => 'integer',
	is_nullable => 0,
};

#    ease            integer not null,
#       -- which button you pushed to score your recall.
#       -- review:  1(wrong), 2(hard), 3(ok), 4(easy)
#       -- learn/relearn:   1(wrong), 2(ok), 3(easy)
column ease => {

};

#    ivl             integer not null,
#       -- interval
column ivl => {
	data_type => 'integer',
	is_nullable => 0,
};

#    lastIvl         integer not null,
#       -- last interval
column lastIvl => {
	data_type => 'integer',
	is_nullable => 0,
};

#    factor          integer not null,
#      -- factor
column factor => {
	data_type => 'integer',
	is_nullable => 0,
};

#    time            integer not null,
#       -- how many milliseconds your review took, up to 60000 (60s)
column time => {
	data_type => 'integer',
	is_nullable => 0,
};

#    type            integer not null
#       --  0=learn, 1=review, 2=relearn, 3=cram
column type => {
	data_type => 'integer',
	is_nullable => 0,
};

1;
