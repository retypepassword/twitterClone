use utf8;
package twitterClone::Schema::Result::TweetTo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

twitterClone::Schema::Result::TweetTo

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<tweet_to>

=cut

__PACKAGE__->table("tweet_to");

=head1 ACCESSORS

=head2 tweet_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "tweet_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</tweet_id>

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("tweet_id", "user_id");

=head1 RELATIONS

=head2 tweet

Type: belongs_to

Related object: L<twitterClone::Schema::Result::Tweet>

=cut

__PACKAGE__->belongs_to(
  "tweet",
  "twitterClone::Schema::Result::Tweet",
  { id => "tweet_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 user

Type: belongs_to

Related object: L<twitterClone::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "twitterClone::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2015-01-21 23:58:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hOy8I5RLjiBymwDHKdN15w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
