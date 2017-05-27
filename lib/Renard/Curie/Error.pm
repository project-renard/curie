use Modern::Perl;
package Renard::Curie::Error;
# ABSTRACT: Exceptions

use custom::failures qw/
	IO::FileNotFound
	User::InvalidPageNumber
	/;

1;
