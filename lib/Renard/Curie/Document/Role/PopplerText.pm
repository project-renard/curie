use Renard::Incunabula::Common::Setup;
package Renard::Curie::Document::Role::PopplerText;
# ABSTRACT: Role to provide text from Poppler's pdftotext

use Moo::Role;

use Alien::Poppler;
use Capture::Tiny qw(capture_merged);

method pdftotext_text( :$pages = undef ) {
	my $pdftotext = Alien::Poppler->pdftotext_path;

	if( ! defined $pages ) {
		$pages = [ $self->first_page_number, $self->last_page_number ];
	} elsif( ! ref $pages ) {
		$pages = [ $pages, $pages ];
	}
	my @page_args = ( qw(-f), $pages->[0], qw(-l), $pages->[1] );
	my ($merged, $result) = capture_merged {
		system($pdftotext, @page_args, $self->filename , qw(-));
	};

	die "pdftotext failed" if $result !=0;

	$merged;
}

1;
