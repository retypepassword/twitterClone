package twitterClone::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'twitterClone::Schema',
    
    connect_info => {
        dsn => 'dbi:mysql:twitterClone',
        user => 'twitterClone',
        password => 'i_like_apple_sauce',
        AutoCommit => q{1},
    }
);

=head1 NAME

twitterClone::Model::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<twitterClone>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<twitterClone::Schema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.6

=head1 AUTHOR

Eric Fleming Lin

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
