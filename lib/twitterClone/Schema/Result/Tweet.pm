use utf8;
package twitterClone::Schema::Result::Tweet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

twitterClone::Schema::Result::Tweet

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

=head1 TABLE: C<tweet>

=cut

__PACKAGE__->table("tweet");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 text

  data_type: 'varchar'
  is_nullable: 1
  size: 151

=head2 date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "text",
  { data_type => "varchar", is_nullable => 1, size => 151 },
  "date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 tweet_hashtags

Type: has_many

Related object: L<twitterClone::Schema::Result::TweetHashtag>

=cut

__PACKAGE__->has_many(
  "tweet_hashtags",
  "twitterClone::Schema::Result::TweetHashtag",
  { "foreign.tweet_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tweets_to

Type: has_many

Related object: L<twitterClone::Schema::Result::TweetTo>

=cut

__PACKAGE__->has_many(
  "tweets_to",
  "twitterClone::Schema::Result::TweetTo",
  { "foreign.tweet_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 tags

Type: many_to_many

Composing rels: L</tweet_hashtags> -> tag

=cut

__PACKAGE__->many_to_many("tags", "tweet_hashtags", "tag");

=head2 users

Type: many_to_many

Composing rels: L</tweets_to> -> user

=cut

__PACKAGE__->many_to_many("users", "tweets_to", "user");


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2015-01-23 13:24:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ECZzSU31ICSEMvY8AkBZQw

sub updateTable {
  my ($self, $type, $items, $table_name, $relationship) = @_;
  my $schema = $self->result_source->schema;

  for my $item (@$items) {
    my $item_obj = $schema->resultset($table_name)->find_or_create({ $type => $item });
    $schema->resultset($relationship)->find_or_create({ tweet_id => $self->id,
                                                         $type.'_id' => $item_obj->id
                                                      });
  }
}

sub updateTagsAndPeople {
  my $self = shift;
  # Code for updating tags and people (adds relationships from tweet to relevant hashtags and people)
  my $html = $self->text;
  my @tags = ($html =~ /#([[:alnum:]]*)/);
  my @people = ($html =~ /@([[:alnum:]]*)/);

  $self->updateTable("tag", \@tags, 'Hashtag', 'TweetHashtag');
  $self->updateTable("user", \@people, 'User', 'TweetTo');
}

# TODO: Make another column to store results of this sub in the table
# (perhaps do it in the subroutine updateTagsAndPeople)
sub html {
  my $self = shift;
  if ( $self->text =~ /[#@]/ ) {
    my $html = $self->text;
    $html =~ s/#([[:alnum:]]*)/<a href="\/hashtag\/$1">#$1<\/a>/g;
    $html =~ s/@([[:alnum:]]*)/<a href="\/$1">\@$1<\/a>/g;
    return $html;
  }
  else {
    return $self->text;
  }
}

sub getDate {
  my $self = shift;
  return $self->date->set_time_zone('UTC')->set_time_zone('America/Los_Angeles')->strftime("%A, %B %d, %Y at %I:%M %p");
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
