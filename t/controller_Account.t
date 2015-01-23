use strict;
use warnings;
use Test::More;


use Catalyst::Test 'twitterClone';
use twitterClone::Controller::Account;

ok( request('/account')->is_success, 'Request should succeed' );
done_testing();
