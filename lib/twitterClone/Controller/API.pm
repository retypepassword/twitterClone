package twitterClone::Controller::API;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

sub tweet : Local ActionClass('REST') { }

sub tweet_POST {
  my ($self, $c) = @_;
 
  # Retrieve tweet from params
  my $text = $c->request->params->{tweet} || '';

  my $wholetweet = $c->model('DB::Tweet')->create({
    text => $text,
    user_id => 1,
    date => DateTime->now
  });

  $wholetweet->updateTagsAndPeople();
  $self->status_created(
    $c,
    location => $c->req->uri->as_string,
    entity => {
      text => $wholetweet->html(),
      username => $wholetweet->user->username,
      author => $wholetweet->user->name,
      date => $wholetweet->date->strftime("%A, %B %d, %Y"),
    },
  );
}


=encoding utf8

=head1 AUTHOR

Eric Fleming Lin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
