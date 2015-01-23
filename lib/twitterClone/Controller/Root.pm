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

    $c->stash(
      search_results => 1,
      tweets => $tweets,
      template => 'index.tt2');
}

sub tweet :Path('/tweet') {
  my ($self, $c) = @_;

  $c->forward('/api/tweet');
  $c->res->redirect($c->uri_for('/'));
  $c->detach();
}

sub hashtag :PathPart('hashtag') :Chained('/') :Args(1) {
  my ($self, $c, $tag) = @_;

  $c->stash->{query} = '#'.$tag;

  $c->detach('search');
}

sub search :PathPart('search') :Chained('/') :Args(1) {
  my ($self, $c, $query) = @_;

  $query = $c->stash->{query} || $c->request->params->{query} || $query;
  
  my ($tweets, $joins, $search_col);

  if ($query =~ /^#/) {
    $query =~ s/#//g;
    $joins = [ { 'user' => 'followed_followeds' }, { 'tweet_hashtags' => 'tag' } ];
    $search_col = 'tag.tag';
  }
  else {
    $joins = { 'user' => 'followed_followeds' };
    $search_col = 'me.text';
  }

  # $c->session->{user_id}
  $tweets = $c->model('DB')->resultset('Tweet')->search(
    [ -and => [
        -or => [
          'user.private' => '0',
          'followed_followeds.follower_id' => 1
        ],
        $search_col => { -like => '%'.$query.'%' }
      ],
    ],
    { join => $joins,
      order_by => { '-desc' => ['me.date']} },
  );

  $c->stash(
    search_results => 1,
    tweets => $tweets,
    template => 'index.tt2');
}

sub userpages :PathPart('') :Chained('/') Args(1) {
  my ($self, $c, $user) = @_;

  my $u = $c->model('DB')->resultset('User')->find({ 'user' => $user });

  if (defined $u) {
    my $uid = $u->id;
    
    # $c->session->{user_id}
    my $is_followed = $c->model('DB')->resultset('Followed')->find({ followed_id => $uid, follower_id => 1 });
    my $constraints = [ { 'followed_followeds.follower_id' => $uid }, { 'me.user_id' => $uid }, { 'tweets_to.user_id' => $uid } ];

    if ( ! defined $is_followed ) { # || $c->session->{user_id} == $uid
      # select * from tweet me join user user on user.id = me.user_id left join followed followed on me.user_id = followed.followed_id left join tweet_to tweet_to on tweet_to.tweet_id = me.id where (followed.follower_id = 2 OR me.user_id = 2 OR tweet_to.user_id = 2) AND user.private = '0'; The 2 is the current user's id.
     $constraints = [ -and => [ $constraints, { 'user.private' => '0' } ] ];
    }

    my $followed_tweets = $c->model('DB')->resultset('Tweet')->search(
      $constraints,
      { join => [ { 'user' => 'followed_followeds' }, 'tweets_to' ],
        order_by => { '-desc' => ['me.date']} },
    );

    $c->stash(
      is_followed => $is_followed,
      user => $u,
      tweets => $followed_tweets,
      template => 'index.tt2');
  }
  else {
    $c->stash->{username} = $user;
    $c->stash->{template} = 'error.tt2';
  }
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
