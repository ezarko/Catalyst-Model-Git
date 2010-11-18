package Catalyst::Helper::Model::Git;
use strict;
use warnings;

sub mk_compclass {
    my ($self, $helper, $work_tree) = @_;
    my $file = $helper->{file};
    $helper->{'work_tree'}  = $work_tree  || die 'No work_tree specified!';

    $helper->render_file('model', $file);
};

sub mk_comptest {
    my ($self, $helper) = @_;
    my $test = $helper->{'test'};

    $helper->render_file('test', $test);
};

1;
__DATA__
__model__
package [% class %];
use strict;
use warnings;
use base 'Catalyst::Model::Git';

__PACKAGE__->config(
    work_tree => '[% work_tree %]'
);

1;
__test__
use Test::More tests => 2;
use strict;
use warnings;

use_ok(Catalyst::Test, '[% app %]');
use_ok('[% class %]');
__END__

=head1 NAME

Catalyst::Helper::Model::Git - Helper for Git Models

=head1 SYNOPSIS

    script/create.pl model <newclass> Git <work_tree>
    script/create.pl model Git Git /path/to/git/work_tree

=head1 DESCRIPTION

A Helper for creating models to browse Git repositories.

=head1 METHODS

=head2 mk_compclass

Makes a Git Model class for you.

=head2 mk_comptest

Makes a Git Model test for you.

=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Helper>, L<Catalyst::Model::Git>

=head1 AUTHOR

    Eric A. Zarko
    CPAN ID: EZARKO
    eric@zarko.org
    http://www.zarko.org/
