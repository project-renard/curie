use Renard::Curie::Setup;
package Renard::Curie::Model::Document::Role::FromFile;
# ABSTRACT: Role that provides a filename for a document

use Moo::Role;
use Renard::Curie::Types qw(File FileUri);

=attr filename

A C<File> containing the path to a document.

=cut
has filename => (
	is => 'ro',
	isa => File,
	coerce => 1,
);

=attr filename_uri

A C<FileUri> containing the path to the document as a URI.

=cut
has filename_uri => (
	is => 'lazy', # _build_filename_uri
	isa => FileUri,
);

method _build_filename_uri() :ReturnType(FileUri) {
	FileUri->coerce($self->filename);
}

1;
