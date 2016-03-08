package Renard::Curie::Data::PDF;

use Modern::Perl;
use Capture::Tiny qw(capture_stdout);

sub mudraw_get_pdf_page_as_png {
	my ($pdf_filename, $pdf_page_no) = @_;

	my ($stdout, $exit) = capture_stdout {
		system("mudraw",
			qw( -F png ),
			qw( -o -),
			$pdf_filename,
			$pdf_page_no,
		);
	};

	die "Unexpected mudraw exit: $exit" if $exit;

	return $stdout;
}

sub get_pdfinfo_for_filename {
	my ($pdf_filename) = @_;

	my ($stdout, $exit) = capture_stdout {
		system("pdfinfo", $pdf_filename);
	};

	my %info = $stdout =~ /
			(?<key> [^:]*? )
			:\s*
			(?<value> .* )
			\n
		/xmg;

	return \%info;
}

sub get_mutool_pages_for_filename {
	...
}


1;
