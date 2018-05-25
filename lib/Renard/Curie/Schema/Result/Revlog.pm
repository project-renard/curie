use Modern::Perl;
package Renard::Curie::Schema::Result::Revlog;

use DBIx::Class::Candy
	-autotable => v1;

#    id              integer primary key,
#       -- epoch-milliseconds timestamp of when you did the review
#    cid             integer not null,
#       -- cards.id
#    usn             integer not null,
#        -- update sequence number: for finding diffs when syncing.
#        --   See the description in the cards table for more info
#    ease            integer not null,
#       -- which button you pushed to score your recall.
#       -- review:  1(wrong), 2(hard), 3(ok), 4(easy)
#       -- learn/relearn:   1(wrong), 2(ok), 3(easy)
#    ivl             integer not null,
#       -- interval
#    lastIvl         integer not null,
#       -- last interval
#    factor          integer not null,
#      -- factor
#    time            integer not null,
#       -- how many milliseconds your review took, up to 60000 (60s)
#    type            integer not null
#       --  0=learn, 1=review, 2=relearn, 3=cram

1;
