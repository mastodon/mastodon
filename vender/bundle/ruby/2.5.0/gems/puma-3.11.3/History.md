## 3.11.3 / 2018-03-05

* 3 bugfixes:
  * Add closed? to MiniSSL::Socket for use in reactor (#1510)
  * Handle EOFError at the toplevel of the server threads (#1524) (#1507)
  * Deal with zero sized bodies when using SSL (#1483)

## 3.11.2 / 2018-01-19

* 1 bugfix:
  * Deal with read\_nonblock returning nil early

## 3.11.1 / 2018-01-18

* 1 bugfix:
  * Handle read\_nonblock returning nil when the socket close (#1502)

## 3.11.0 / 2017-11-20

* 2 features:
  * HTTP 103 Early Hints (#1403)
  * 421/451 status codes now have correct status messages attached (#1435)

* 9 bugfixes:
  * Environment config files (/config/puma/<ENV>.rb) load correctly (#1340)
  * Specify windows dependencies correctly (#1434, #1436)
  * puma/events required in test helper (#1418)
  * Correct control CLI's option help text (#1416)
  * Remove a warning for unused variable in mini_ssl (#1409)
  * Correct pumactl docs argument ordering (#1427)
  * Fix an uninitialized variable warning in server.rb (#1430)
  * Fix docs typo/error in Launcher init (#1429)
  * Deal with leading spaces in RUBYOPT (#1455)

* 2 other:
  * Add docs about internals (#1425, #1452)
  * Tons of test fixes from @MSP-Greg (#1439, #1442, #1464)

## 3.10.0 / 2017-08-17

* 3 features:
  * The status server has a new /gc and /gc-status command. (#1384)
  * The persistent and first data timeouts are now configurable (#1111)
  * Implemented RFC 2324 (#1392)

* 12 bugfixes:
  * Not really a Puma bug, but @NickolasVashchenko created a gem to workaround a Ruby bug that some users of Puma may be experiencing. See README for more. (#1347)
  * Fix hangups with SSL and persistent connections. (#1334)
  * Fix Rails double-binding to a port (#1383)
  * Fix incorrect thread names (#1368)
  * Fix issues with /etc/hosts and JRuby where localhost addresses were not correct. (#1318)
  * Fix compatibility with RUBYOPT="--enable-frozen-string-literal" (#1376)
  * Fixed some compiler warnings (#1388)
  * We actually run the integration tests in CI now (#1390)
  * No longer shipping unnecessary directories in the gemfile (#1391)
  * If RUBYOPT is nil, we no longer blow up on restart. (#1385)
  * Correct response to SIGINT (#1377)
  * Proper exit code returned when we receive a TERM signal (#1337)

* 3 refactors:
  * Various test improvements from @grosser
  * Rubocop (#1325)
  * Hoe has been removed (#1395)

* 1 known issue:
  * Socket activation doesn't work in JRuby. Their fault, not ours. (#1367)

## 3.9.1 / 2017-06-03

* 2 bugfixes:
  * Fixed compatibility with older Bundler versions (#1314)
  * Some internal test/development cleanup (#1311, #1313)

## 3.9.0 / 2017-06-01

* 2 features:
  * The ENV is now reset to its original values when Puma restarts via USR1/USR2 (#1260) (MRI only, no JRuby support)
  * Puma will no longer accept more clients than the maximum number of threads. (#1278)

* 9 bugfixes:
  * Reduce information leakage by preventing HTTP parse errors from writing environment hashes to STDERR (#1306)
  * Fix SSL/WebSocket compatibility (#1274)
  * HTTP headers with empty values are no longer omitted from responses. (#1261)
  * Fix a Rack env key which was set to nil. (#1259)
  * peercert has been implemented for JRuby (#1248)
  * Fix port settings when using rails s (#1277, #1290)
  * Fix compat w/LibreSSL (#1285)
  * Fix restarting Puma w/symlinks and a new Gemfile (#1282)
  * Replace Dir.exists? with Dir.exist? (#1294)

* 1 known issue:
  * A bug in MRI 2.2+ can result in IOError: stream closed. See #1206. This issue has existed since at least Puma 3.6, and probably further back.

* 1 refactor:
  * Lots of test fixups from @grosser.

## 3.8.2 / 2017-03-14

* 1 bugfix:
  * Deal with getsockopt with TCP\_INFO failing for sockets that say they're TCP but aren't really. (#1241)

## 3.8.1 / 2017-03-10

* 1 bugfix:
  * Remove method call to method that no longer exists (#1239)

## 3.8.0 / 2017-03-09

* 2 bugfixes:
  * Port from rack handler does not take precedence over config file in Rails 5.1.0.beta2+ and 5.0.1.rc3+ (#1234)
  * The `tmp/restart.txt` plugin no longer restricts the user from running more than one server from the same folder at a time (#1226)

* 1 feature:
  * Closed clients are aborted to save capacity (#1227)

* 1 refactor:
  * Bundler is no longer a dependency from tests (#1213)

## 3.7.1 / 2017-02-20

* 2 bugfixes:
  * Fix typo which blew up MiniSSL (#1182)
  * Stop overriding command-line options with the config file (#1203)

## 3.7.0 / 2017-01-04

* 6 minor features:
  * Allow rack handler to accept ssl host. (#1129)
  * Refactor TTOU processing. TTOU now handles multiple signals at once. (#1165)
  * Pickup any remaining chunk data as the next request.
  * Prevent short term thread churn - increased auto trim default to 30 seconds.
  * Raise error when `stdout` or `stderr` is not writable. (#1175)
  * Add Rack 2.0 support to gemspec. (#1068)

* 5 refactors:
  * Compare host and server name only once per call. (#1091)
  * Minor refactor on Thread pool (#1088)
  * Removed a ton of unused constants, variables and files.
  * Use MRI macros when allocating heap memory
  * Use hooks for on\_booted event. (#1160)

* 14 bugfixes:
  * Add eof? method to NullIO? (#1169)
  * Fix Puma startup in provided init.d script (#1061)
  * Fix default SSL mode back to none. (#1036)
  * Fixed the issue of @listeners getting nil io (#1120)
  * Make `get_dh1024` compatible with OpenSSL v1.1.0 (#1178)
  * More gracefully deal with SSL sessions. Fixes #1002
  * Move puma.rb to just autoloads. Fixes #1063
  * MiniSSL: Provide write as <<. Fixes #1089
  * Prune bundler should inherit fds (#1114)
  * Replace use of Process.getpgid which does not behave as intended on all platforms (#1110)
  * Transfer encoding header should be downcased before comparison (#1135)
  * Use same write log logic for hijacked requests. (#1081)
  * Fix `uninitialized constant Puma::StateFile` (#1138)
  * Fix access priorities of each level in LeveledOptions (#1118)

* 3 others:

  * Lots of tests added/fixed/improved. Switched to Minitest from Test::Unit. Big thanks to @frodsan.
  * Lots of documentation added/improved.
  * Add license indicators to the HTTP extension. (#1075)

## 3.6.2 / 2016-11-22

* 1 bug fix:

  * Revert #1118/Fix access priorities of each level in LeveledOptions. This
    had an unintentional side effect of changing the importance of command line
    options, such as -p.

## 3.6.1 / 2016-11-21

* 8 bug fixes:

  * Fix Puma start in init.d script.
  * Fix default SSL mode back to none. Fixes #1036
  * Fixed the issue of @listeners getting nil io, fix rails restart (#1120)
  * More gracefully deal with SSL sessions. Fixes #1002
  * Prevent short term thread churn.
  * Provide write as <<. Fixes #1089
  * Fix access priorities of each level in LeveledOptions - fixes TTIN.
  * Stub description files updated for init.d.

* 2 new project committers:

  * Nate Berkopec (@nateberkopec)
  * Richard Schneeman (@schneems)

## 3.6.0 / 2016-07-24

* 12 bug fixes:
  * Add ability to detect a shutting down server. Fixes #932
  * Add support for Expect: 100-continue. Fixes #519
  * Check SSLContext better. Fixes #828
  * Clarify behavior of '-t num'. Fixes #984
  * Don't default to VERIFY_PEER. Fixes #1028
  * Don't use ENV['PWD'] on windows. Fixes #1023
  * Enlarge the scope of catching app exceptions. Fixes #1027
  * Execute background hooks after daemonizing. Fixes #925
  * Handle HUP as a stop unless there is IO redirection. Fixes #911
  * Implement chunked request handling. Fixes #620
  * Just rescue exception to return a 500. Fixes #1027
  * Redirect IO in the jruby daemon mode. Fixes #778

## 3.5.2 / 2016-07-20

* 1 bug fix:
  * Don't let persistent_timeout be nil

* 1 PR merged:
  * Merge pull request #1021 from benzrf/patch-1

## 3.5.1 / 2016-07-20

* 1 bug fix:
  * Be sure to only listen on host:port combos once. Fixes #1022

## 3.5.0 / 2016-07-18

* 1 minor features:
  * Allow persistent_timeout to be configured via the dsl.

* 9 bug fixes:
  * Allow a bare % in a query string. Fixes #958
  * Explicitly listen on all localhost addresses. Fixes #782
  * Fix `TCPLogger` log error in tcp cluster mode.
  * Fix puma/puma#968 Cannot bind SSL port due to missing verify_mode option
  * Fix puma/puma#968 Default verify_mode to peer
  * Log any exceptions in ThreadPool. Fixes #1010
  * Silence connection errors in the reactor. Fixes #959
  * Tiny fixes in hook documentation for #840
  * It should not log requests if we want it to be quiet

* 5 doc fixes:
  * Add How to stop Puma on Heroku using plugins to the example directory
  * Provide both hot and phased restart in jungle script
  * Update reference to the instances management script
  * Update default number of threads
  * Fix typo in example config

* 14 PRs merged:
  * Merge pull request #1007 from willnet/patch-1
  * Merge pull request #1014 from jeznet/patch-1
  * Merge pull request #1015 from bf4/patch-1
  * Merge pull request #1017 from jorihardman/configurable_persistent_timeout
  * Merge pull request #954 from jf/master
  * Merge pull request #955 from jf/add-request-info-to-standard-error-rescue
  * Merge pull request #956 from maxkwallace/master
  * Merge pull request #960 from kmayer/kmayer-plugins-heroku-restart
  * Merge pull request #969 from frankwong15/master
  * Merge pull request #970 from willnet/delete-blank-document
  * Merge pull request #974 from rocketjob/feature/name_threads
  * Merge pull request #977 from snow/master
  * Merge pull request #981 from zach-chai/patch-1
  * Merge pull request #993 from scorix/master

## 3.4.0 / 2016-04-07

* 2 minor features:
  * Add ability to force threads to stop on shutdown. Fixes #938
  * Detect and commit seppuku when fork(2) fails. Fixes #529

* 3 unknowns:
  * Ignore errors trying to update the backport tables. Fixes #788
  * Invoke the lowlevel_error in more places to allow for exception tracking. Fixes #894
  * Update the query string when an absolute URI is used. Fixes #937

* 5 doc fixes:
  * Add Process Monitors section to top-level README
  * Better document the hooks. Fixes #840
  * docs/system.md sample config refinements and elaborations
  * Fix typos at couple of places.
  * Cleanup warnings

* 3 PRs merged:
  * Merge pull request #945 from dekellum/systemd-docs-refined
  * Merge pull request #946 from vipulnsward/rm-pid
  * Merge pull request #947 from vipulnsward/housekeeping-typos

## 3.3.0 / 2016-04-05

* 2 minor features:
  * Allow overriding options of Configuration object
  * Rename to inherit_ssl_listener like inherit_tcp|unix

* 2 doc fixes:
  * Add docs/systemd.md (with socket activation sub-section)
  * Document UNIX signals with cluster on README.md

* 3 PRs merged:
  * Merge pull request #936 from prathamesh-sonpatki/allow-overriding-config-options
  * Merge pull request #940 from kyledrake/signalsdoc
  * Merge pull request #942 from dekellum/socket-activate-improve

## 3.2.0 / 2016-03-20

* 1 deprecation removal:
  * Delete capistrano.rb

* 3 bug fixes:
  * Detect gems.rb as well as Gemfile
  * Simplify and fix logic for directory to use when restarting for all phases
  * Speed up phased-restart start

* 2 PRs merged:
  * Merge pull request #927 from jlecour/gemfile_variants
  * Merge pull request #931 from joneslee85/patch-10

## 3.1.1 / 2016-03-17

* 4 bug fixes:
  * Disable USR1 usage on JRuby
  * Fixes #922 - Correctly define file encoding as UTF-8
  * Set a more explicit SERVER_SOFTWARE Rack variable
  * Show RUBY_ENGINE_VERSION if available. Fixes #923

* 3 PRs merged:
  * Merge pull request #912 from tricknotes/fix-allow-failures-in-travis-yml
  * Merge pull request #921 from swrobel/patch-1
  * Merge pull request #924 from tbrisker/patch-1

## 3.1.0 / 2016-03-05

* 1 minor feature:
  * Add 'import' directive to config file. Fixes #916

* 5 bug fixes:
  * Add 'fetch' to options. Fixes #913
  * Fix jruby daemonization. Fixes #918
  * Recreate the proper args manually. Fixes #910
  * Require 'time' to get iso8601. Fixes #914

## 3.0.2 / 2016-02-26

* 5 bug fixes:

  * Fix 'undefined local variable or method `pid` for #<Puma::ControlCLI:0x007f185fcef968>' when execute pumactl with `--pid` option.
  * Fix 'undefined method `windows?` for Puma:Module' when execute pumactl.
  * Harden tmp_restart against errors related to the restart file
  * Make `plugin :tmp_restart` behavior correct in Windows.
  * fix uninitialized constant Puma::ControlCLI::StateFile

* 3 PRs merged:

  * Merge pull request #901 from mitto/fix-pumactl-uninitialized-constant-statefile
  * Merge pull request #902 from corrupt952/fix_undefined_method_and_variable_when_execute_pumactl
  * Merge pull request #905 from Eric-Guo/master

## 3.0.1 / 2016-02-25

* 1 bug fix:

  * Removed the experimental support for async.callback as it broke
    websockets entirely. Seems no server has both hijack and async.callback
    and thus faye is totally confused what to do and doesn't work.

## 3.0.0 / 2016-02-25

* 2 major changes:

  * Ruby pre-2.0 is no longer supported. We'll do our best to not add
    features that break those rubies but will no longer be testing
    with them.
  * Don't log requests by default. Fixes #852

* 2 major features:

  * Plugin support! Plugins can interact with configuration as well
    as provide augment server functionality!
  * Experimental env['async.callback'] support

* 4 minor features:

  * Listen to unix socket with provided backlog if any
  * Improves the clustered stats to report worker stats
  * Pass the env to the lowlevel_error handler. Fixes #854
  * Treat path-like hosts as unix sockets. Fixes #824

* 5 bug fixes:

  * Clean thread locals when using keepalive. Fixes #823
  * Cleanup compiler warnings. Fixes #815
  * Expose closed? for use by the reactor. Fixes #835
  * Move signal handlers to separate method to prevent space leak. Fixes #798
  * Signal not full on worker exit #876

* 5 doc fixes:

  * Update README.md with various grammar fixes
  * Use newest version of Minitest
  * Add directory configuration docs, fix typo [ci skip]
  * Remove old COPYING notice. Fixes #849

* 10 merged PRs:

  * Merge pull request #871 from deepj/travis
  * Merge pull request #874 from wallclockbuilder/master
  * Merge pull request #883 from dadah89/igor/trim_only_worker
  * Merge pull request #884 from uistudio/async-callback
  * Merge pull request #888 from mlarraz/tick_minitest
  * Merge pull request #890 from todd/directory_docs
  * Merge pull request #891 from ctaintor/improve_clustered_status
  * Merge pull request #893 from spastorino/add_missing_require
  * Merge pull request #897 from zendesk/master
  * Merge pull request #899 from kch/kch-readme-fixes

## 2.16.0 / 2016-01-27

* 7 minor features:

  * Add 'set_remote_address' config option
  * Allow to run puma in silent mode
  * Expose cli options in DSL
  * Support passing JRuby keystore info in ssl_bind DSL
  * Allow umask for unix:/// style control urls
  * Expose `old_worker_count` in stats url
  * Support TLS client auth (verify_mode) in jruby

* 7 bug fixes:

  * Don't persist before_fork hook in state file
  * Reload bundler before pulling in rack. Fixes #859
  * Remove NEWRELIC_DISPATCHER env variable
  * Cleanup C code
  * Use Timeout.timeout instead of Object.timeout
  * Make phased restarts faster
  * Ignore the case of certain headers, because HTTP

* 1 doc changes:

  * Test against the latest Ruby 2.1, 2.2, 2.3, head and JRuby 9.0.4.0 on Travis

* 12 merged PRs
  * Merge pull request #822 from kwugirl/remove_NEWRELIC_DISPATCHER
  * Merge pull request #833 from joemiller/jruby-client-tls-auth
  * Merge pull request #837 from YuriSolovyov/ssl-keystore-jruby
  * Merge pull request #839 from mezuka/master
  * Merge pull request #845 from deepj/timeout-deprecation
  * Merge pull request #846 from sriedel/strip_before_fork
  * Merge pull request #850 from deepj/travis
  * Merge pull request #853 from Jeffrey6052/patch-1
  * Merge pull request #857 from zendesk/faster_phased_restarts
  * Merge pull request #858 from mlarraz/fix_some_warnings
  * Merge pull request #860 from zendesk/expose_old_worker_count
  * Merge pull request #861 from zendesk/allow_control_url_umask

## 2.15.3 / 2015-11-07

* 1 bug fix:

  * Fix JRuby parser

## 2.15.2 / 2015-11-06

* 2 bug fixes:
  * ext/puma_http11: handle duplicate headers as per RFC
  * Only set ctx.ca iff there is a params['ca'] to set with.

* 2 PRs merged:
  * Merge pull request #818 from unleashed/support-duplicate-headers
  * Merge pull request #819 from VictorLowther/fix-ca-and-verify_null-exception

## 2.15.1 / 2015-11-06

* 1 bug fix:

  * Allow older openssl versions

## 2.15.0 / 2015-11-06

* 6 minor features:
  * Allow setting ca without setting a verify mode
  * Make jungle for init.d support rbenv
  * Use SSL_CTX_use_certificate_chain_file for full chain
  * cluster: add worker_boot_timeout option
  * configuration: allow empty tags to mean no tag desired
  * puma/cli: support specifying STD{OUT,ERR} redirections and append mode

* 5 bug fixes:
  * Disable SSL Compression
  * Fix bug setting worker_directory when using a symlink directory
  * Fix error message in DSL that was slightly inaccurate
  * Pumactl: set correct process name. Fixes #563
  * thread_pool: fix race condition when shutting down workers

* 10 doc fixes:
  * Add before_fork explanation in Readme.md
  * Correct spelling in DEPLOYMENT.md
  * Correct spelling in docs/nginx.md
  * Fix spelling errors.
  * Fix typo in deployment description
  * Fix typos (it's -> its) in events.rb and server.rb
  * fixing for typo mentioned in #803
  * Spelling correction for README
  * thread_pool: fix typos in comment
  * More explicit docs for worker_timeout

* 18 PRs merged:
  * Merge pull request #768 from nathansamson/patch-1
  * Merge pull request #773 from rossta/spelling_corrections
  * Merge pull request #774 from snow/master
  * Merge pull request #781 from sunsations/fix-typo
  * Merge pull request #791 from unleashed/allow_empty_tags
  * Merge pull request #793 from robdimarco/fix-working-directory-symlink-bug
  * Merge pull request #794 from peterkeen/patch-1
  * Merge pull request #795 from unleashed/redirects-from-cmdline
  * Merge pull request #796 from cschneid/fix_dsl_message
  * Merge pull request #799 from annafw/master
  * Merge pull request #800 from liamseanbrady/fix_typo
  * Merge pull request #801 from scottjg/ssl-chain-file
  * Merge pull request #802 from scottjg/ssl-crimes
  * Merge pull request #804 from burningTyger/patch-2
  * Merge pull request #809 from unleashed/threadpool-fix-race-in-shutdown
  * Merge pull request #810 from vlmonk/fix-pumactl-restart-bug
  * Merge pull request #814 from schneems/schneems/worker_timeout-docs
  * Merge pull request #817 from unleashed/worker-boot-timeout

## 2.14.0 / 2015-09-18

* 1 minor feature:
  * Make building with SSL support optional

* 1 bug fix:
  * Use Rack::Builder if available. Fixes #735

## 2.13.4 / 2015-08-16

* 1 bug fix:
  * Use the environment possible set by the config early and from
    the config file later (if set).

## 2.13.3 / 2015-08-15

Seriously, I need to revamp config with tests.

* 1 bug fix:
  * Fix preserving options before cleaning for state. Fixes #769

## 2.13.2 / 2015-08-15

The "clearly I don't have enough tests for the config" release.

* 1 bug fix:
  * Fix another place binds wasn't initialized. Fixes #767

## 2.13.1 / 2015-08-15

* 2 bug fixes:
  * Fix binds being masked in config files. Fixes #765
  * Use options from the config file properly in pumactl. Fixes #764

## 2.13.0 / 2015-08-14

* 1 minor feature:
  * Add before_fork hooks option.

* 3 bug fixes:
  * Check for OPENSSL_NO_ECDH before using ECDH
  * Eliminate logging overhead from JRuby SSL
  * Prefer cli options over config file ones. Fixes #669

* 1 deprecation:
  * Add deprecation warning to capistrano.rb. Fixes #673

* 4 PRs merged:
  * Merge pull request #668 from kcollignon/patch-1
  * Merge pull request #754 from nathansamson/before_boot
  * Merge pull request #759 from BenV/fix-centos6-build
  * Merge pull request #761 from looker/no-log

## 2.12.3 / 2015-08-03

* 8 minor bugs fixed:
  * Fix Capistrano 'uninitialized constant Puma' error.
  * Fix some ancient and incorrect error handling code
  * Fix uninitialized constant error
  * Remove toplevel rack interspection, require rack on load instead
  * Skip empty parts when chunking
  * Switch from inject to each in config_ru_binds iteration
  * Wrap SSLv3 spec in version guard.
  * ruby 1.8.7 compatibility patches

* 4 PRs merged:
  * Merge pull request #742 from deivid-rodriguez/fix_missing_require
  * Merge pull request #743 from matthewd/skip-empty-chunks
  * Merge pull request #749 from huacnlee/fix-cap-uninitialized-puma-error
  * Merge pull request #751 from costi/compat_1_8_7

* 1 test fix:
  * Add 1.8.7, rbx-1 (allow failures) to Travis.

## 2.12.2 / 2015-07-17

* 2 bug fix:
  * Pull over and use Rack::URLMap. Fixes #741
  * Stub out peercert on JRuby for now. Fixes #739

## 2.12.1 / 2015-07-16

* 2 bug fixes:
  * Use a constant format. Fixes #737
  * Use strerror for Windows sake. Fixes #733

* 1 doc change:
  * typo fix: occured -> occurred

* 1 PR merged:
  * Merge pull request #736 from paulanunda/paulanunda/typo-fix

## 2.12.0 / 2015-07-14

* 13 bug fixes:
  * Add thread reaping to thread pool
  * Do not automatically use chunked responses when hijacked
  * Do not suppress Content-Length on partial hijack
  * Don't allow any exceptions to terminate a thread
  * Handle ENOTCONN client disconnects when setting REMOTE_ADDR
  * Handle very early exit of cluster mode. Fixes #722
  * Install rack when running tests on travis to use rack/lint
  * Make puma -v and -h return success exit code
  * Make pumactl load config/puma.rb by default
  * Pass options from pumactl properly when pruning. Fixes #694
  * Remove rack dependency. Fixes #705
  * Remove the default Content-Type: text/plain
  * Add Client Side Certificate Auth

* 8 doc/test changes:
  * Added example sourcing of environment vars
  * Added tests for bind configuration on rackup file
  * Fix example config text
  * Update DEPLOYMENT.md
  * Update Readme with example of custom error handler
  * ci: Improve Travis settings
  * ci: Start running tests against JRuby 9k on Travis
  * ci: Convert to container infrastructure for travisci

* 2 ops changes:
  * Check for system-wide rbenv
  * capistrano: Add additional env when start rails

* 16 PRs merged:
  * Merge pull request #686 from jjb/patch-2
  * Merge pull request #693 from rob-murray/update-example-config
  * Merge pull request #697 from spk/tests-bind-on-rackup-file
  * Merge pull request #699 from deees/fix/require_rack_builder
  * Merge pull request #701 from deepj/master
  * Merge pull request #702 from Jimdo/thread-reaping
  * Merge pull request #703 from deepj/travis
  * Merge pull request #704 from grega/master
  * Merge pull request #709 from lian/master
  * Merge pull request #711 from julik/master
  * Merge pull request #712 from yakara-ltd/pumactl-default-config
  * Merge pull request #715 from RobotJiang/master
  * Merge pull request #725 from rwz/master
  * Merge pull request #726 from strenuus/handle-client-disconnect
  * Merge pull request #729 from allaire/patch-1
  * Merge pull request #730 from iamjarvo/container-infrastructure

## 2.11.3 / 2015-05-18

* 5 bug fixes:
  * Be sure to unlink tempfiles after a request. Fixes #690
  * Coerce the key to a string before checking. (thar be symbols). Fixes #684
  * Fix hang on bad SSL handshake
  * Remove `enable_SSLv3` support from JRuby

* 1 PR merged:
  * Merge pull request #698 from looker/hang-handshake

## 2.11.2 / 2015-04-11

* 2 minor features:
  * Add `on_worker_fork` hook, which allows to mimic Unicorn's behavior
  * Add shutdown_debug config option

* 4 bug fixes:
  * Fix the Config constants not being available in the DSL. Fixes #683
  * Ignore multiple port declarations
  * Proper 'Connection' header handling compatible with HTTP 1.[01] protocols
  * Use "Puma" instead of "puma" to reporting to New Relic

* 1 doc fixes:
  * Add Gitter badge.

* 6 PRs merged:
  * Merge pull request #657 from schneems/schneems/puma-once-port
  * Merge pull request #658 from Tomohiro/newrelic-dispatcher-default-update
  * Merge pull request #662 from basecrm/connection-compatibility
  * Merge pull request #664 from fxposter/on-worker-fork
  * Merge pull request #667 from JuanitoFatas/doc/gemspec
  * Merge pull request #672 from chulkilee/refactor

## 2.11.1 / 2015-02-11

* 2 bug fixes:
  * Avoid crash in strange restart conditions
  * Inject the GEM_HOME that bundler into puma-wild's env. Fixes #653

* 2 PRs merged:
  * Merge pull request #644 from bpaquet/master
  * Merge pull request #646 from mkonecny/master

## 2.11.0 / 2015-01-20

* 9 bug fixes:
  * Add mode as an additional bind option to unix sockets. Fixes #630
  * Advertise HTTPS properly after a hot restart
  * Don't write lowlevel_error_handler to state
  * Fix phased restart with stuck requests
  * Handle spaces in the path properly. Fixes #622
  * Set a default REMOTE_ADDR to avoid using peeraddr on unix sockets. Fixes #583
  * Skip device number checking on jruby. Fixes #586
  * Update extconf.rb to compile correctly on OS X
  * redirect io right after daemonizing so startup errors are shown. Fixes #359

* 6 minor features:
  * Add a configuration option that prevents puma from queueing requests.
  * Add reload_worker_directory
  * Add the ability to pass environment variables to the init script (for Jungle).
  * Add the proctitle tag to the worker. Fixes #633
  * Infer a proctitle tag based on the directory
  * Update lowlevel error message to be more meaningful.

* 10 PRs merged:
  * Merge pull request #478 from rubencaro/master
  * Merge pull request #610 from kwilczynski/master
  * Merge pull request #611 from jasonl/better-lowlevel-message
  * Merge pull request #616 from jc00ke/master
  * Merge pull request #623 from raldred/patch-1
  * Merge pull request #628 from rdpoor/master
  * Merge pull request #634 from deepj/master
  * Merge pull request #637 from raskhadafi/patch-1
  * Merge pull request #639 from ebeigarts/fix-phased-restarts
  * Merge pull request #640 from codehotter/issue-612-dependent-requests-deadlock

## 2.10.2 / 2014-11-26

* 1 bug fix:
  * Conditionalize thread local cleaning, fixes perf degradation fix
    The code to clean out all Thread locals adds pretty significant
    overhead to a each request, so it has to be turned on explicitly
    if a user needs it.

## 2.10.1 / 2014-11-24

* 1 bug fix:
  * Load the app after daemonizing because the app might start threads.

  This change means errors loading the app are now reported only in the redirected
  stdout/stderr.

  If you're app has problems starting up, start it without daemon mode initially
  to test.

## 2.10.0 / 2014-11-23

* 3 minor features:
  * Added on_worker_shutdown hook mechanism
  * Allow binding to ipv6 addresses for ssl URIs
  * Warn about any threads started during app preload

* 5 bug fixes:
  * Clean out a threads local data before doing work
  * Disable SSLv3. Fixes #591
  * First change the directory to use the correct Gemfile.
  * Only use config.ru binds if specified. Fixes #606
  * Strongish cipher suite with FS support for some browsers

* 2 doc changes:
  * Change umask examples to more permissive values
  * fix typo in README.md

* 9 Merged PRs:
  * Merge pull request #560 from raskhadafi/prune_bundler-bug
  * Merge pull request #566 from sheltond/master
  * Merge pull request #593 from andruby/patch-1
  * Merge pull request #594 from hassox/thread-cleanliness
  * Merge pull request #596 from burningTyger/patch-1
  * Merge pull request #601 from sorentwo/friendly-umask
  * Merge pull request #602 from 1334/patch-1
  * Merge pull request #608 from Gu1/master
  * Merge remote-tracking branch 'origin/pr/538'

## 2.9.2 / 2014-10-25

* 8 bug fixes:
  * Fix puma-wild handling a restart properly. Fixes #550
  * JRuby SSL POODLE update
  * Keep deprecated features warnings
  * Log the current time when Puma shuts down.
  * Fix cross-platform extension library detection
  * Use the correct Windows names for OpenSSL.
  * Better error logging during startup
  * Fixing sexist error messages

* 6 PRs merged:
  * Merge pull request #549 from bsnape/log-shutdown-time
  * Merge pull request #553 from lowjoel/master
  * Merge pull request #568 from mariuz/patch-1
  * Merge pull request #578 from danielbuechele/patch-1
  * Merge pull request #581 from alexch/slightly-better-logging
  * Merge pull request #590 from looker/jruby_disable_sslv3

## 2.9.1 / 2014-09-05

* 4 bug fixes:
  * Cleanup the SSL related structures properly, fixes memory leak
  * Fix thread spawning edge case.
  * Force a worker check after a worker boots, don't wait 5sec. Fixes #574
  * Implement SIGHUP for logs reopening

* 2 PRs merged:
  * Merge pull request #561 from theoldreader/sighup
  * Merge pull request #570 from havenwood/spawn-thread-edge-case

## 2.9.0 / 2014-07-12

* 1 minor feature:
  * Add SSL support for JRuby

* 3 bug fixes:
  * Typo BUNDLER_GEMFILE -> BUNDLE_GEMFILE
  * Use fast_write because we can't trust syswrite
  * pumactl - do not modify original ARGV

* 4 doc fixes:
  * BSD-3-Clause over BSD to avoid confusion
  * Deploy doc: clarification of the GIL
  * Fix typo in DEPLOYMENT.md
  * Update README.md

* 6 PRs merged:
  * Merge pull request #520 from misfo/patch-2
  * Merge pull request #530 from looker/jruby-ssl
  * Merge pull request #537 from vlmonk/patch-1
  * Merge pull request #540 from allaire/patch-1
  * Merge pull request #544 from chulkilee/bsd-3-clause
  * Merge pull request #551 from jcxplorer/patch-1

## 2.8.2 / 2014-04-12

* 4 bug fixes:
  * During upgrade, change directory in main process instead of workers.
  * Close the client properly on error
  * Capistrano: fallback from phased restart to start when not started
  * Allow tag option in conf file

* 4 doc fixes:
  * Fix Puma daemon service README typo
  * `preload_app!` instead of `preload_app`
  * add preload_app and prune_bundler to example config
  * allow changing of worker_timeout in config file

* 11 PRs merged:
  * Merge pull request #487 from ckuttruff/master
  * Merge pull request #492 from ckuttruff/master
  * Merge pull request #493 from alepore/config_tag
  * Merge pull request #503 from mariuz/patch-1
  * Merge pull request #505 from sammcj/patch-1
  * Merge pull request #506 from FlavourSys/config_worker_timeout
  * Merge pull request #510 from momer/rescue-block-handle-servers-fix
  * Merge pull request #511 from macool/patch-1
  * Merge pull request #514 from edogawaconan/refactor_env
  * Merge pull request #517 from misfo/patch-1
  * Merge pull request #518 from LongMan/master

## 2.8.1 / 2014-03-06

* 1 bug fixes:
  * Run puma-wild with proper deps for prune_bundler

* 2 doc changes:
  * Described the configuration file finding behavior added in 2.8.0 and how to disable it.
  * Start the deployment doc

* 6 PRs merged:
  * Merge pull request #471 from arthurnn/fix_test
  * Merge pull request #485 from joneslee85/patch-9
  * Merge pull request #486 from joshwlewis/patch-1
  * Merge pull request #490 from tobinibot/patch-1
  * Merge pull request #491 from brianknight10/clarify-no-config

## 2.8.0 / 2014-02-28

* 8 minor features:
  * Add ability to autoload a config file. Fixes #438
  * Add ability to detect and terminate hung workers. Fixes #333
  * Add booted_workers to stats response
  * Add config to customize the default error message
  * Add prune_bundler option
  * Add worker indexes, expose them via on_worker_boot. Fixes #440
  * Add pretty process name
  * Show the ruby version in use

* 7 bug fixes:
  * Added 408 status on timeout.
  * Be more hostile with sockets that write block. Fixes #449
  * Expect at_exit to exclusively remove the pidfile. Fixes #444
  * Expose latency and listen backlog via bind query. Fixes #370
  * JRuby raises IOError if the socket is there. Fixes #377
  * Process requests fairly. Fixes #406
  * Rescue SystemCallError as well. Fixes #425

* 4 doc changes:
  * Add 2.1.0 to the matrix
  * Add Code Climate badge to README
  * Create signals.md
  * Set the license to BSD. Fixes #432

* 14 PRs merged:
  * Merge pull request #428 from alexeyfrank/capistrano_default_hooks
  * Merge pull request #429 from namusyaka/revert-const_defined
  * Merge pull request #431 from mrb/master
  * Merge pull request #433 from alepore/process-name
  * Merge pull request #437 from ibrahima/master
  * Merge pull request #446 from sudara/master
  * Merge pull request #451 from pwiebe/status_408
  * Merge pull request #453 from joevandyk/patch-1
  * Merge pull request #470 from arthurnn/fix_458
  * Merge pull request #472 from rubencaro/master
  * Merge pull request #480 from jjb/docs-on-running-test-suite
  * Merge pull request #481 from schneems/master
  * Merge pull request #482 from prathamesh-sonpatki/signals-doc-cleanup
  * Merge pull request #483 from YotpoLtd/master

## 2.7.1 / 2013-12-05

* 1 bug fix:

  * Keep STDOUT/STDERR the right mode. Fixes #422

## 2.7.0 / 2013-12-03

* 1 minor feature:
  * Adding TTIN and TTOU to increment/decrement workers

* N bug fixes:
  * Always use our Process.daemon because it's not busted
  * Add capistrano restart failback to start.
  * Change position of `cd` so that rvm gemset is loaded
  * Clarify some platform specifics
  * Do not close the pipe sockets when retrying
  * Fix String#byteslice for Ruby 1.9.1, 1.9.2
  * Fix compatibility with 1.8.7.
  * Handle IOError closed stream in IO.select
  * Increase the max URI path length to 2048 chars from 1024 chars
  * Upstart jungle use config/puma.rb instead

## 2.6.0 / 2013-09-13

* 2 minor features:
  * Add support for event hooks
  ** Add a hook for state transitions
  * Add phased restart to capistrano recipe.

* 4 bug fixes:
  * Convince workers to stop by SIGKILL after timeout
  * Define RSTRING_NOT_MODIFIED for Rubinius performance
  * Handle BrokenPipe, StandardError and IOError in fat_wrote and break out
  * Return success status to the invoking environment

## 2.5.1 / 2013-08-13

* 2 bug fixes:

  * Keep jruby daemon mode from retrying on a hot restart
  * Extract version from const.rb in gemspec

## 2.5.0 / 2013-08-08

* 2 minor features:
  * Allow configuring pumactl with config.rb
  * make `pumactl restart` start puma if not running

* 6 bug fixes:
  * Autodetect ruby managers and home directory in upstart script
  * Convert header values to string before sending.
  * Correctly report phased-restart availability
  * Fix pidfile creation/deletion race on jruby daemonization
  * Use integers when comparing thread counts
  * Fix typo in using lopez express (raw tcp) mode

* 6 misc changes:
  * Fix typo in phased-restart response
  * Uncomment setuid/setgid by default in upstart
  * Use Puma::Const::PUMA_VERSION in gemspec
  * Update upstart comments to reflect new commandline
  * Remove obsolete pumactl instructions; refer to pumactl for details
  * Make Bundler used puma.gemspec version agnostic

## 2.4.1 / 2013-08-07

* 1 experimental feature:
  * Support raw tcp servers (aka Lopez Express mode)

## 2.4.0 / 2013-07-22

* 5 minor features:
  * Add PUMA_JRUBY_DAEMON_OPTS to get around agent starting twice
  * Add ability to drain accept socket on shutdown
  * Add port to DSL
  * Adds support for using puma config file in capistrano deploys.
  * Make phased_restart fallback to restart if not available

* 10 bug fixes:

  * Be sure to only delete the pid in the master. Fixes #334
  * Call out -C/--config flags
  * Change parser symbol names to avoid clash. Fixes #179
  * Convert thread pool sizes to integers
  * Detect when the jruby daemon child doesn't start properly
  * Fix typo in CLI help
  * Improve the logging output when hijack is used. Fixes #332
  * Remove unnecessary thread pool size conversions
  * Setup :worker_boot as an Array. Fixes #317
  * Use 127.0.0.1 as REMOTE_ADDR of unix client. Fixes #309


## 2.3.2 / 2013-07-08

* 1 bug fix:

  * Move starting control server to after daemonization.

## 2.3.1 / 2013-07-06

* 2 bug fixes:

  * Include the right files in the Manifest.
  * Disable inheriting connections on restart on windows. Fixes #166

* 1 doc change:
  * Better document some platform constraints

## 2.3.0 / 2013-07-05

* 1 major bug fix:

  * Stabilize control server, add support in cluster mode

* 5 minor bug fixes:

  * Add ability to cleanup stale unix sockets
  * Check status data better. Fixes #292
  * Convert raw IO errors to ConnectionError. Fixes #274
  * Fix sending Content-Type and Content-Length for no body status. Fixes #304
  * Pass state path through to `pumactl start`. Fixes #287

* 2 internal changes:

  * Refactored modes into seperate classes that CLI uses
  * Changed CLI to take an Events object instead of stdout/stderr (API change)

## 2.2.2 / 2013-07-02

* 1 bug fix:

  * Fix restart_command in the config

## 2.2.1 / 2013-07-02

* 1 minor feature:

  * Introduce preload flag

* 1 bug fix:

  * Pass custom restart command in JRuby

## 2.2.0 / 2013-07-01

* 1 major feature:

  * Add ability to preload rack app

* 2 minor bugfixes:

  * Don't leak info when not in development. Fixes #256
  * Load the app, then bind the ports

## 2.1.1 / 2013-06-20

* 2 minor bug fixes:

  * Fix daemonization on jruby
  * Load the application before daemonizing. Fixes #285

## 2.1.0 / 2013-06-18

* 3 minor features:
  * Allow listening socket to be configured via Capistrano variable
  * Output results from 'stat's command when using pumactl
  * Support systemd socket activation

* 15 bug fixes:
  * Deal with pipes closing while stopping. Fixes #270
  * Error out early if there is no app configured
  * Handle ConnectionError rather than the lowlevel exceptions
  * tune with `-C` config file and `on_worker_boot`
  * use `-w`
  * Fixed some typos in upstart scripts
  * Make sure to use bytesize instead of size (MiniSSL write)
  * Fix an error in puma-manager.conf
  * fix: stop leaking sockets on restart (affects ruby 1.9.3 or before)
  * Ignore errors on the cross-thread pipe. Fixes #246
  * Ignore errors while uncorking the socket (it might already be closed)
  * Ignore the body on a HEAD request. Fixes #278
  * Handle all engine data when possible. Fixes #251.
  * Handle all read exceptions properly. Fixes #252
  * Handle errors from the server better

* 3 doc changes:
  * Add note about on_worker_boot hook
  * Add some documentation for Clustered mode
  * Added quotes to /etc/puma.conf

## 2.0.1 / 2013-04-30

* 1 bug fix:

  * Fix not starting on JRuby properly

## 2.0.0 / 2013-04-29

RailsConf 2013 edition!

* 2 doc changes:
  * Start with rackup -s Puma, NOT rackup -s puma.
  * Minor doc fixes in the README.md, Capistrano section

* 2 bug fixes:
  * Fix reading RACK_ENV properly. Fixes #234
  * Make cap recipe handle tmp/sockets; fixes #228

* 3 minor changes:
  * Fix capistrano recipe
  * Fix stdout/stderr logs to sync outputs
  * allow binding to IPv6 addresses

## 2.0.0.b7 / 2013-03-18

* 5 minor enhancements:

  * Add -q option for :start
  * Add -V, --version
  * Add default Rack handler helper
  * Upstart support
  * Set worker directory from configuration file

* 12 bug fixes:

  * Close the binder in the right place. Fixes #192
  * Handle early term in workers. Fixes #206
  * Make sure that the default port is 80 when the request doesn't include HTTP_X_FORWARDED_PROTO.
  * Prevent Errno::EBADF errors on restart when running ruby 2.0
  * Record the proper @master_pid
  * Respect the header HTTP_X_FORWARDED_PROTO when the host doesn't include a port number.
  * Retry EAGAIN/EWOULDBLOCK during syswrite
  * Run exec properly to restart. Fixes #154
  * Set Rack run_once to false
  * Syncronize all access to @timeouts. Fixes #208
  * Write out the state post-daemonize. Fixes #189
  * Prevent crash when all workers are gone

## 2.0.0.b6 / 2013-02-06

* 2 minor enhancements:

  * Add hook for running when a worker boots
  * Advertise the Configuration object for apps to use.

* 1 bug fix:

  * Change directory in working during upgrade. Fixes #185

## 2.0.0.b5 / 2013-02-05

* 2 major features:
  * Add phased worker upgrade
  * Add support for the rack hijack protocol

* 2 minor features:
  * Add -R to specify the restart command
  * Add config file option to specify the restart command

* 5 bug fixes:
  * Cleanup pipes properly. Fixes #182
  * Daemonize earlier so that we don't lose app threads. Fixes #183
  * Drain the notification pipe. Fixes #176, thanks @cryo28
  * Move write_pid to after we daemonize. Fixes #180
  * Redirect IO properly and emit message for checkpointing

## 2.0.0.b4 / 2012-12-12

* 4 bug fixes:
  * Properly check #syswrite's value for variable sized buffers. Fixes #170
  * Shutdown status server properly
  * Handle char vs byte and mixing syswrite with write properly
  * made MiniSSL validate key/cert file existence

## 2.0.0.b3 / 2012-11-22

* 1 bug fix:
  * Package right files in gem

## 2.0.0.b2 / 2012-11-18
* 5 minor feature:
  * Now Puma is bundled with an capistrano recipe. Just require
     'puma/capistrano' in you deploy.rb
  * Only inject CommonLogger in development mode
  * Add -p option to pumactl
  * Add ability to use pumactl to start a server
  * Add options to daemonize puma

* 7 bug fixes:
  * Reset the IOBuffer properly. Fixes #148
  * Shutdown gracefully on JRuby with Ctrl-C
  * Various methods to get newrelic to start. Fixes #128
  * fixing syntax error at capistrano recipe
  * Force ECONNRESET when read returns nil
  * Be sure to empty the drain the todo before shutting down. Fixes #155
  * allow for alternate locations for status app

## 2.0.0.b1 / 2012-09-11

* 1 major feature:
  * Optional worker process mode (-w) to allow for process scaling in
    addition to thread scaling

* 1 bug fix:
  * Introduce Puma::MiniSSL to be able to properly control doing
    nonblocking SSL

NOTE: SSL support in JRuby is not supported at present. Support will
be added back in a future date when a java Puma::MiniSSL is added.

## 1.6.3 / 2012-09-04

* 1 bug fix:
  * Close sockets waiting in the reactor when a hot restart is performed
    so that browsers reconnect on the next request

## 1.6.2 / 2012-08-27

* 1 bug fix:
  * Rescue StandardError instead of IOError to handle SystemCallErrors
    as well as other application exceptions inside the reactor.

## 1.6.1 / 2012-07-23

* 1 packaging bug fixed:
  * Include missing files

## 1.6.0 / 2012-07-23

* 1 major bug fix:
  * Prevent slow clients from starving the server by introducing a
    dedicated IO reactor thread. Credit for reporting goes to @meh.

## 1.5.0 / 2012-07-19

* 7 contributors to this release:
  * Christian Mayer
  * Darío Javier Cravero
  * Dirkjan Bussink
  * Gianluca Padovani
  * Santiago Pastorino
  * Thibault Jouan
  * tomykaira

* 6 bug fixes:
  * Define RSTRING_NOT_MODIFIED for Rubinius
  * Convert status to integer. Fixes #123
  * Delete pidfile when stopping the server
  * Allow compilation with -Werror=format-security option
  * Fix wrong HTTP version for a HTTP/1.0 request
  * Use String#bytesize instead of String#length

* 3 minor features:
  * Added support for setting RACK_ENV via the CLI, config file, and rack app
  * Allow Server#run to run sync. Fixes #111
  * Puma can now run on windows

## 1.4.0 / 2012-06-04

* 1 bug fix:
  * SCRIPT_NAME should be passed from env to allow mounting apps

* 1 experimental feature:
  * Add puma.socket key for direct socket access

## 1.3.1 / 2012-05-15

* 2 bug fixes:
  * use #bytesize instead of #length for Content-Length header
  * Use StringIO properly. Fixes #98

## 1.3.0 / 2012-05-08

* 2 minor features:
  * Return valid Rack responses (passes Lint) from status server
  * Add -I option to specify $LOAD_PATH directories

* 4 bug fixes:
  * Don't join the server thread inside the signal handle. Fixes #94
  * Make NullIO#read mimic IO#read
  * Only stop the status server if it's started. Fixes #84
  * Set RACK_ENV early in cli also. Fixes #78

* 1 new contributor:
  * Jesse Cooke

## 1.2.2 / 2012-04-28

* 4 bug fixes:

  * Report a lowlevel error to stderr
  * Set a fallback SERVER_NAME and SERVER_PORT
  * Keep the encoding of the body correct. Fixes #79
  * show error.to_s along with backtrace for low-level error

## 1.2.1 / 2012-04-11

 1 bug fix:

   * Fix rack.url_scheme for SSL servers. Fixes #65

## 1.2.0 / 2012-04-11

 1 major feature:

   * When possible, the internal restart does a "hot restart" meaning
     the server sockets remains open, so no connections are lost.

 1 minor feature:

    * More helpful fallback error message

 6 bug fixes:

    * Pass the proper args to unknown_error. Fixes #54, #58
    * Stop the control server before restarting. Fixes #61
    * Fix reporting https only on a true SSL connection
    * Set the default content type to 'text/plain'. Fixes #63
    * Use REUSEADDR. Fixes #60
    * Shutdown gracefully on SIGTERM. Fixes #53

 2 new contributors:

   * Seamus Abshere
   * Steve Richert

## 1.1.1 / 2012-03-30

 1 bugfix:

   * Include puma/compat.rb in the gem (oops!)

## 1.1.0 / 2012-03-30

 1 bugfix:

   * Make sure that the unix socket has the perms 0777 by default

 1 minor feature:

   * Add umask param to the unix:// bind to set the umask

## 1.0.0 / 2012-03-29

* Released!
