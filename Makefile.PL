use inc::Module::Install;

name 'Media-Mogul';
all_from 'lib/Media/Mogul.pm';

requires 'Moose';
requires 'Moose::Types::UUID';

requires 'MooseX::Storage';

feature 'Simple FileSystem Storage',
    -default => 1,
    'JSON::XS';

feature 'MogileFS Storage',
    -default => 0,
    'MogileFS::Client';
