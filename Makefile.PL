use ExtUtils::MakeMaker;
use 5.008;
use strict;
use warnings;

WriteMakefile(
    NAME         => 'Catalyst::Model::Git',
    VERSION_FROM => 'lib/Catalyst/Model/Git.pm',
    AUTHOR       => 'Eric A. Zarko <ezarko@synacor.com>',
    ABSTRACT     => 'Catalyst Model to browse Git repositories',
    PREREQ_PM    => {
        'Catalyst::Runtime'     => 0,
        'Catalyst::Devel'       => 0, # Build dep
        'Git::Repository'       => 0,
        'Path::Class'           => 0,
        'DateTime'              => 0,
        'Scalar::Util'          => 0,
    },
    dist => {
        PREOP => 'pod2text lib/Catalyst/Model/Git.pm > $(DISTVNAME)/README',
    },
    clean => { FILES => 't/TestApp'},
);
