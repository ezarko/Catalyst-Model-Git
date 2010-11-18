package Catalyst::Model::Git::Item;

use strict;
use warnings;

use Carp qw( confess );
use DateTime;
use Path::Class qw( dir file );
use Scalar::Util qw( blessed );

use overload '""' => \&stringify, fallback => 1;

our $VERSION = '0.1';

sub new {
    my ( $class, @args ) = @_;
    my $self = bless {@args}, ref($class) || $class;

    return $self;
}

# construction accessors
sub author {
    my $self = shift;
    return "$self->{author_name} <$self->{author_email}>";
}

sub author_email {
    my $self = shift;
    return $self->{author_email};
}

sub author_name {
    my $self = shift;
    return $self->{author_name};
}

sub author_time {
    my $self = shift;
    my $time = $self->{author_time};

    if ( !blessed($time) ) {
        $time = DateTime->from_epoch( epoch => $time );
        $time->set_time_zone('UTC');
        $self->{author_time} = $time;
    }

    return $time;
}

sub commit {
    my $self = shift;
    return $self->{commit};
}

sub committer {
    my $self = shift;
    return "$self->{commit_name} <$self->{commit_email}>";
}

sub commit_email {
    my $self = shift;
    return $self->{commit_email};
}

sub commit_name {
    my $self = shift;
    return $self->{commit_name};
}

sub commit_time {
    my $self = shift;
    my $time = $self->{commit_time};

    if ( !blessed($time) ) {
        $time = DateTime->from_epoch( epoch => $time );
        $time->set_time_zone('UTC');
        $self->{commit_time} = $time;
    }

    return $time;
}

sub message {
    my $self = shift;
    return $self->{message};
}

sub mode {
    my $self = shift;
    return $self->{mode};
}

sub oid {
    my $self = shift;
    return $self->{oid};
}

sub parent {
    my $self = shift;
    return $self->{parent};
}

sub path {
    my $self = shift;
    return $self->{path}->stringify;
}

sub size {
    my $self = shift;
    return $self->{size};
}

sub tree {
    my $self = shift;
    return $self->{tree};
}

# git accessors
sub contents {
    my $self = shift;

    if (!exists($self->{contents})) {
        if ($self->is_file) {
            $self->{contents} = [$self->{repo}->run('cat-file' => $self->{type} => $self->{oid})];
        } else {
            $self->{contents} = [$self->{git}->ls($self->path.'/', $self->{treeish})];
        }
    }

    return wantarray ? @{$self->{contents}} : join "\n", @{$self->{contents}}, '';
}

# Path::Class accessors
sub is_directory {
    my $self = shift;
    return $self->{path}->is_dir;
}

sub is_file {
    my $self = shift;
    return $self->{path}->is_dir ? 0 : 1;
}

sub name {
    my $self = shift;
    return $self->{name} ||=
        (ref $self->{path} eq 'Path::Class::File')
        ? $self->{path}->basename
        : $self->{path}->dir_list(-1);
}

# aliases
sub stringify {
    my $self = shift;
    return $self->name;
}

sub time {
    my $self = shift;
    return $self->author_time;
}

1;

__END__

=head1 NAME

Catalyst::Model::Git::Item - Object representing a file or directory in a git repository.

=head1 SYNOPSIS

See L<Catalyst::Model::Git>

=head1 DESCRIPTION

This class provides an interface to any versioned item in Git.

=head1 METHODS

=head2 author

Returns the author of the item in "name <email>" format.

=head2 author_email

Returns the email of the author of the item.

=head2 author_name

Returns the name of the author of the item.

=head2 author_time

Returns the timestamp of the item.

=head2 commit

Returns the commit hash of the item.

=head2 committer

Returns the committer of the item in "name <email>" format.

=head2 commit_email

Returns the email of the committer of the item.

=head2 commit_name

Returns the name of the committer of the item.

=head2 commit_time

Returns the timestamp of the commit of the item.

=head2 contents

Returns the contents of the item.

=head2 is_directory

Returns 1 if the item is a directory; 0 otherwise.

=head2 is_file

Returns 1 if the item is a file; 0 otherwise.

=head2 message

Returns the commit message of the item.

=head2 mode

Returns the mode of the item. (See L<File::stat>)

=head2 name

Returns the name of the item.

=head2 oid

Returns the object is of the item.

=head2 parent

Returns the parent hash of the item.

=head2 path

Returns the path of the item relative to the repository root.

=head2 size

Returns the raw file size in bytes for the item, if the item is a file.
Returns undef if the item is a directory.

=head2 stringify

Alias for C<name>.

=head2 time

Alias for C<author_time>.

=head2 tree

Returns the tree hash of the item.

=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Helper>, L<Catalyst::Model::Git>, L<Git::Repository>

=head1 AUTHORS

    Eric A. Zarko
    CPAN ID: EZARKO
    ezarko@synacor.com

=head1 LICENSE

        Copyright (c) 2010 the aforementioned authors. All rights
        reserved. This program is free software; you can redistribute
        it and/or modify it under the same terms as Perl itself.

