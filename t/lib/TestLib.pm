package TestLib;
use strict;
use warnings;
use File::Temp qw( tempdir );
use Git::Repository;

sub new {
    my ( $class ) = @_;
    my $self = {};
    return bless $self, $class;
}

sub create_git_repos {
    my ( $self ) = @_;

    $self->{options} = {
        env => {
            GIT_AUTHOR_EMAIL => 'author@example.com',
            GIT_AUTHOR_NAME  => 'Test Author',
            GIT_COMMITTER_EMAIL => 'committer@example.com',
            GIT_COMMITTER_NAME  => 'Test Committer',
        },
    };

    $self->{tempdir} = tempdir();
    warn('Created temp directory at ' . $self->{tempdir}) if $ENV{DEBUG_TEST};

    chdir($self->{tempdir}) || die 'Could not change to temp directory';

    # Create
    my $repo = Git::Repository->create(init => 'repo', $self->{options}) || die('failed to create repository');

    # Commit 1
    {
        my $F;
        open($F, '>', 'repo/f1') || die;
        print $F "File 1, rev 1\n";
        close $F;
    };

    my $cmd = $repo->command(add => 'f1');
    $cmd->close;
    die('Adding first file failed')
        if ($cmd->exit);
    $cmd = $repo->command(commit => '-m', 'make file, commit 1');
    $cmd->close;
    die('commit 1 failed')
        if ($cmd->exit);

    # Commit 2
    mkdir('repo/subdir') || die;
    {
        my $F;
        open($F, '>', 'repo/subdir/f2') || die;
        print $F "File 2, rev 1\n";
        close $F;
    };

    $cmd = $repo->command(add => 'subdir/f2');
    $cmd->close;
    die('Adding subdir and second file failed')
        if ($cmd->exit);
    $cmd = $repo->command(commit => '-m', 'make subdir and file, commit 2');
    $cmd->close;
    die('commit 2 failed')
        if ($cmd->exit);

    # Grab the commit id
    $cmd = $repo->command('log' => '--pretty=format:%H');
    my $log = $cmd->stdout;
    my $commit = <$log>;
    chomp $commit;
    $cmd->close;
    die('log failed')
        if ($cmd->exit || !$commit);

    # Commit 3
    $cmd = $repo->command(mv => 'subdir/f2' => 'subdir/f2.moved');
    $cmd->close;
    die('Move file failed')
        if ($cmd->exit);
    $cmd = $repo->command('commit', '-m', 'do a move, commit 3');
    $cmd->close;
    die('commit 3 failed')
        if ($cmd->exit);

    # Commit 4
    $cmd = $repo->command(mv => 'subdir' => 'subdir.moved');
    $cmd->close;
    die('Move dir failed')
        if ($cmd->exit);
    $cmd = $repo->command(commit => '-m', 'do another move, commit 4');
    $cmd->close;
    die('commit 4 failed')
        if ($cmd->exit);

    # Clone
    my $clone = Git::Repository->create(clone => 'repo' => 'repo_clone') || die('clone did not work');

    # Reset
    $cmd = $clone->command(reset => '--hard', $commit);
    $cmd->close;
    die('reset failed')
        if ($cmd->exit);

    warn('Finished creating repository, returning ' . $self->{tempdir} . '/repo') if $ENV{DEBUG_TEST};

    return $self->{tempdir} . '/repo';
}

sub DESTROY {
    my ( $self ) = @_;
    system('rm -rf ' . $self->{tempdir});
}

1;
