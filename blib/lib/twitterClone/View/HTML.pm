package twitterClone::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    # TEMPLATE_EXTENSION => '.tt',
    WRAPPER => 'wrapper.tt2',
    render_die => 1,
);

=head1 NAME

twitterClone::View::HTML - TT View for twitterClone

=head1 DESCRIPTION

TT View for twitterClone.

=head1 SEE ALSO

L<twitterClone>

=head1 AUTHOR

Eric Fleming Lin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
