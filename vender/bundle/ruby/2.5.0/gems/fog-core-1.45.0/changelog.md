1.45.0 08/01/2017
==========================================================

remove xmlrpc requirement/usage
fix for nested const across ruby versions
remove array#sample usage for legacy ruby compatibility
simplify uniq for cache and fix for legacy ruby
remove debugging puts from cache
tweak tins version for 1.9
loosen 2.1.x travis config to 2.1
add 1.9 compatible term-ansicolor
fix rubocop for 1.9.3
enable metadata for cache
add specs for server#sshable
add exponential backoff for server#sshable?
add server#ready? to base server for clarity
bump excon dependency

1.44.3 05/25/2017
==========================================================

fix cache when no home directory defined

1.44.2 05/18/2017
==========================================================

fix homedirectory usage for caching

1.44.1 05/01/2017
==========================================================

remove xml-rpc dependency (as it is causing issues)

1.44.0 04/28/2017
==========================================================

add basic caching support

1.43.0 09/28/2016
==========================================================

fix digitalocean compatibility
update README badges

1.42.0 07/05/2016
==========================================================

make namespace detection fix 1.8.x compatible

1.41.0 07/01/2016
==========================================================

bump as 1.40.1 is not showing up in some cases

1.40.1 06/28/2016
==========================================================

fix namespace constant detection

1.40.0 05/19/2016
==========================================================

add minitest helpers for schema (parity to shindo)

1.39.0 05/11/2016
==========================================================

cleanup warnings
add NFV module
only dup frozen strings

1.38.0 04/20/2016
==========================================================

more specific service not found error
fix string freeze issue for ruby 2.3
bump excon dep

1.37.0 03/31/2016
==========================================================

remove hp from providers
re-raise mime-type error, rather than exiting
fix tests
add introspection module

1.36.0 02/23/2016
==========================================================

default digitalocean to v2
fix eager/auto-loading
add cloud-at-cost

1.35.0 11/24/2015
==========================================================

make mime/types require optional
fix warnings about net-ssh vs net-cp

1.34.0 11/16/2015
==========================================================

make net/ssh and net/scp requires optional

1.33.0 11/15/2015
==========================================================

relax net/ssh and net/scp requirement

1.32.1 08/12/2015
==========================================================

expose identities in models

1.32.0 07/02/2015
==========================================================

fix/refactor service initializers

1.31.1 06/17/2015
==========================================================

fixes around unknown providers/services

1.31.0 06/17/2015
==========================================================

use relative paths
add digital ocean examples
reinstate baremetal
add softlayer examples
add digital ocean v2 support
setup fog model equality to check identities (if available)
use Fog.interval in wait_for
reduce memory footprint
fix account handling

1.30.0 04/02/2015
==========================================================

bump excon dep
use float times, instead of integers for Fog::Time
don't raise if final wait_for yield true
fix bug around formatador and #map on models
fix around `to_time` to avoid conflicts with Rails monkey patches
update specs
update style
fix `WhitelistKeys` for 1.8.7
remove unreachable code
convert hash helpers to minispec
fix require order for coverage
fix ruby 2.2 warning
bump excon dependency
fix readme link

1.29.0 02/19/2015
==========================================================

minor refactoring
add ability to add additional user agent info to requests

1.28.0 01/30/2015
==========================================================

add Fog::Baremetal

1.27.4 01/26/2015
==========================================================

model fix for new formatador usage
fixes around formatador delegation

1.27.3 12/01/2014
==========================================================

rubocop fixes for fog collection
simpler ruby version checking/skipping
fix requires_one

1.27.2 18/12/2014
==========================================================

fix several requires in service abstraction code

1.27.1 12/12/2014
==========================================================

fix typo in model load paths fix

1.27.0 12/12/2014
==========================================================

return fog/bin stuff to fog/fog
add support for multiple request/model load paths


1.26.0 12/02/2014
==========================================================

remove rackspace logic
use new travis builds
fix error handling around credential fetch
move fog/bin stuff to fog-core
fix circular reference in collection.rb


1.25.0 11/18/2014
==========================================================

add alias options for associations
improve spec message
add feature to overwrite keys on hash of attributes generation
remove method_missing from model
add rubocop
fix rubocop warnings
return collections on association getters
fix require bug in service
put fog and fog-core versions in user agent
don't mutate/destroy encoding in get_body_size
fix error output in from const_get usage
separate to have distinct version from fog


1.24.0 08/26/2014
==========================================================

fixes for defaulting attributes
add method for getting all attributes
add methods for associations
add all_attributes, all_associations and all_associations_and_attributes helper methods
remove no-longer-needed gem update on travis
add all_values
fixes to avoid path conflicts with fog/fog

1.23.0 07/16/2014
==========================================================

attribute whitelisting
abstract out stringify for possible reuse
more specific naming
reorg
add path_prefix
fix time conversion to work with XMLRPC
add more specific per-type attribute tests
lock down rest-client for 1.8.7
allow namespace flipflop for dns
fix identity lookup
better default attribute value setting
bump excon

1.22.0 04/17/2014 1c086852e40e4c1ad7ed138834e4a1505ddb1416
==========================================================

attribute whitelisting
abstract out stringify for possible reuse
more specific naming
reorg
add path_prefix
fix time conversion to work with XMLRPC
add more specific per-type attribute tests
lock down rest-client for 1.8.7
allow namespace flipflop for dns
fix identity lookup
better default attribute value setting
bump excon

1.22.0 04/17/2014 1c086852e40e4c1ad7ed138834e4a1505ddb1416
==========================================================

tests/cleanup/fixes

1.21.1 03/18/2014 3a803405ba60ded421f4bd14677cd3c76cb7e6ab
==========================================================

remove json/xml modules and code
add travis/coveralls
update from upstream
bump/loosen excon dependency
