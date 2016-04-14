use Modern::Perl;
package Renard::Curie::Data::PDF;

use Capture::Tiny qw(capture_stdout);
use XML::Simple;

sub _call_mutool {
	my @args = ( "mutool", @_ );
	my ($stdout, $exit) = capture_stdout {
		system( @args );
	};

	die "Unexpected mutool exit: $exit" if $exit;

	return $stdout;
}

sub mudraw_get_pdf_page_as_png {
	my ($pdf_filename, $pdf_page_no) = @_;

	my $stdout = _call_mutool(
		qw(draw),
		qw( -F png ),
		qw( -o -),
		$pdf_filename,
		$pdf_page_no,
	);

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

sub get_mutool_text_stext_raw {
	my ($pdf_filename, $pdf_page_no) = @_;

	my $stdout = _call_mutool(
		qw(draw),
		qw(-F stext),
		qw(-o -),
		$pdf_filename,
		$pdf_page_no,
	);

	return $stdout;
}

sub get_mutool_text_stext_xml {
	my ($pdf_filename, $pdf_page_no) = @_;

	my $stext_xml = get_mutool_text_stext_raw(
		$pdf_filename,
		$pdf_page_no,
	);
	# page -> [list of blocks]
	#   block -> [list of blocks]
	#     block is either:
	#       - stext
	#           line -> [list of lines] (all have same baseline)
	#             span -> [list of spans] (horizontal spaces over a line)
	#               char -> [list of chars]
	#       - image
	#           TODO

	my $stext = XMLin( $stext_xml,
		ForceArray => [ qw(page block line span char) ] );

	return $stext;
}

sub get_mutool_page_info_raw {
	my ($pdf_filename) = @_;

	my $stdout = _call_mutool(
		qw(pages),
		$pdf_filename
	);

	# remove the first line
	$stdout =~ s/^[^\n]*\n//s;

	return $stdout;
}

sub get_mutool_page_info_xml {
	my ($pdf_filename) = @_;

	my $page_info_data = get_mutool_page_info_raw( $pdf_filename );

	# wraps the data with a root node
	my $page_info_xml = "<document>$page_info_data</document>";

	my $page_info = XMLin( $page_info_xml );

	return $page_info;
}


1;
