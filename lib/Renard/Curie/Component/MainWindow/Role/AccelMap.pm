use Renard::Incunabula::Common::Setup;
package Renard::Curie::Component::MainWindow::Role::AccelMap;
# ABSTRACT: Role for accelerators

use Moo::Role;
use Renard::Curie::Component::AccelMap;

after setup_window => method() {
	Renard::Curie::Component::AccelMap->new;
};

1;
