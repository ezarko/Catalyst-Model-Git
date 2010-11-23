package Catalyst::Model::Git;

use strict;
use warnings;

use Carp qw/confess croak/;
use Catalyst::Model::Git::Item;
use Git::Repository;
use Path::Class qw( dir file );
use base 'Catalyst::Model';

our $VERSION = '0.1';

__PACKAGE__->mk_ro_accessors(qw( work_tree options git_dir ));
__PACKAGE__->config();

sub new {
    my $self = shift->next::method(@_);

    croak "->config->{work_tree} must be defined for this model"
        unless $self->{work_tree};

    $self->{repo} = Git::Repository->new( %$self );

    return $self;
}

sub ls {
    my ( $self, $path, $treeish ) = @_;
    $treeish ||= 'HEAD';

    my @nodes = sort {$a->name cmp $b->name} map {
        /^(\d{6}) (tree|blob) ([0-9a-f]{40}) +(-|\d+)\t(.*)$/;
        my @log = $self->{repo}->run(
            'log', '-1', '--pretty=format:%H%n%T%n%P%n%an%n%ae%n%at%n%cn%n%ce%n%ct%n%B', $treeish, $5
        );
        Catalyst::Model::Git::Item->new(
            git          => $self,
            repo         => $self->{repo},
            treeish      => $treeish,
            mode         => oct($1),
            type         => $2,
            oid          => $3,
            size         => $4 eq '-' ? undef : $4,
            path         => $2 eq 'tree' ? dir($5) : file($5),
            commit       => $log[0],
            tree         => $log[1],
            parent       => $log[2],
            author_name  => $log[3],
            author_email => $log[4],
            author_time  => $log[5],
            commit_name  => $log[6],
            commit_email => $log[7],
            commit_time  => $log[8],
            message      => $log[9],
        );
    } $self->{repo}->run('ls-tree' => '-l', $treeish, (defined $path ? $path : ()));

    return wantarray ? @nodes : \@nodes;
}

# cat( $path [, $treeish] )
sub cat {
    my ( $self, $path, $treeish ) = @_;
    my @results = $self->ls($path, $treeish);
    return $results[0]->contents
        if (scalar(@results) == 1 && $results[0]->is_file);
}

1;

__END__

=head1 NAME

Catalyst::Model::Git - Catalyst Model to browse Git repositories

=head1 SYNOPSIS

    # Model
    __PACKAGE__->config(
        work_tree => '/path/to/git/working/folder'
    );

    # Controller
    sub default : Private {
        my ($self, $c) = @_;
        my $path = join('/', $c->req->args);

        $c->stash->{'items'} = MyApp::Model::Git->ls($path);

        $c->stash->{'template'} = 'blog.tt';
    };

=head1 DESCRIPTION

This model class uses Git::Repository to access a Git repository and
list items and view their contents. It is currently only a read-only
client but may expand to be a full fledged client at a later time.

=head1 CONFIG

The following configuration options are available:

=head2 work_tree

Returns the path to the root of your Git working folder.

This value comes from the config key 'work_tree'.

=head2 options

Returns the options passed to the Git::Repository constructor.

This value comes from the config key 'options'.

=head2 git_dir

Returns the path to the root of your Git index folder.

This value comes from the config key 'git_dir'.

=head1 METHODS

=head2 cat($path [, $treeish])

Returns the contents of the C<path> and C<treeish> specified. This is the
same as calling C<Catalyst::Model::Git->ls($path, $treeish)->[0]->contents()>.

Note: $path must be a file, not a directory.

=head2 git_dir

Returns the git_dir specified in the configuration C<git_dir> option.

=head2 ls($path [, $treeish])

In a list context, returns an array of L<Catalyst::Model::Git::Item>
objects of the C<path> and C<treeish> specified, each representing an
entry in the specified work_tree path. In scalar context, it returns
an array reference.

=head2 options

Returns the options specified in the configuration C<options> option.

=head2 work_tree

Returns the work_tree specified in the configuration C<work_tree> option.

=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Helper>, L<Catalyst::Model::Git::Item>, L<Git::Repository>

=head1 AUTHORS

    Eric A. Zarko
    CPAN ID: EZARKO
    ezarko@synacor.com

=head1 LICENSE

        Copyright (c) 2010 the aforementioned authors. All rights
        reserved. This program is free software; you can redistribute
        it and/or modify it under the same terms as Perl itself.

