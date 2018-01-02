use Modern::Perl;
package Renard::Curie::Error;
# ABSTRACT: Exceptions for Curie

use custom::failures qw/
	User::InvalidPageNumber
	ViewOptions::InvalidGridOptions
	/;

1;
