use strict;
use warnings;
use Test::More;


use Catalyst::Test 'twitterClone';
use twitterClone::Controller::API;

ok( request('/api')->is_success, 'Request should succeed' );
done_testing();
