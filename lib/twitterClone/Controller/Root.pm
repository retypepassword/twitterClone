package twitterClone::Controller::Root;
use Moose;
use DateTime;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

twitterClone::Controller::Root - Root Controller for twitterClone

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $tweets = $c->model('DB')->resultset('Tweet')->search(
      { 'user.private' => '0' },
      { join => 'user',
        order_by => { '-desc' => ['me.date']} },
    );

    # select * from tweet me left join followed followed on me.user_id = followed.followed_id left join tweet_to tweet_to on tweet_to.tweet_id = me.id where followed.follower_id = 2 OR me.user_id = 2 OR tweet_to.user_id = 2; The 2 is the current user's id.
    my $followed_tweets = $c->model('DB')->resultset('Tweet')->search(
      [ { 'followed_followeds.follower_id' => 2 }, { 'me.user_id' => 2 }, { 'tweets_to.user_id' => 2 } ],
      { join => [ { 'user' => 'followed_followeds' }, 'tweets_to' ],
        order_by => { '-desc' => ['me.date']} },
    );

    # Hello World
    $c->stash(
      tweets => $followed_tweets,
      template => 'index.tt2');
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Eric Fleming Lin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
