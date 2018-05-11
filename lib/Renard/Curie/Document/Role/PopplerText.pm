use Renard::Incunabula::Common::Setup;
package Renard::Curie::Document::Role::PopplerText;
# ABSTRACT: Role to provide text from Poppler's pdftotext

use Moo::Role;

use Alien::Poppler;
use Capture::Tiny qw(capture_merged);

method pdftotext_text( :$page = undef ) {
	my $pdftotext = Alien::Poppler->pdftotext_path;

	my @page = defined $page ? ( qw(-f), $page, qw(-l), $page ) : ();
	my ($merged, $result) = capture_merged {
		system($pdftotext, @page, $self->filename , qw(-));
	};

	die "pdftotext failed" if $result !=0;

	$merged;
}

1;
