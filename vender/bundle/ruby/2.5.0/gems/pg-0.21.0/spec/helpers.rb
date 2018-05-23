#!/usr/bin/env ruby

require 'pathname'
require 'rspec'
require 'shellwords'
require 'pg'

TEST_DIRECTORY = Pathname.getwd + "tmp_test_specs"

module PG::TestingHelpers

	### Automatically set up the database when it's used, and wrap a transaction around
	### examples that don't disable it.
	def self::included( mod )
		super

		if mod.respond_to?( :around )

			mod.before( :all ) { @conn = setup_testing_db(described_class ? described_class.name : mod.description) }

			mod.around( :each ) do |example|
				begin
					@conn.exec( 'BEGIN' ) unless example.metadata[:without_transaction]
					if PG.respond_to?( :library_version )
						desc = example.source_location.join(':')
						@conn.exec_params %Q{SET application_name TO '%s'} %
							[@conn.escape_string(desc.slice(-60))]
					end
					example.run
				ensure
					@conn.exec( 'ROLLBACK' ) unless example.metadata[:without_transaction]
				end
			end

			mod.after( :all ) { teardown_testing_db(@conn) }
		end

	end


	#
	# Examples
	#

	# Set some ANSI escape code constants (Shamelessly stolen from Perl's
	# Term::ANSIColor by Russ Allbery <rra@stanford.edu> and Zenin <zenin@best.com>
	ANSI_ATTRIBUTES = {
		'clear'      => 0,
		'reset'      => 0,
		'bold'       => 1,
		'dark'       => 2,
		'underline'  => 4,
		'underscore' => 4,
		'blink'      => 5,
		'reverse'    => 7,
		'concealed'  => 8,

		'black'      => 30,   'on_black'   => 40,
		'red'        => 31,   'on_red'     => 41,
		'green'      => 32,   'on_green'   => 42,
		'yellow'     => 33,   'on_yellow'  => 43,
		'blue'       => 34,   'on_blue'    => 44,
		'magenta'    => 35,   'on_magenta' => 45,
		'cyan'       => 36,   'on_cyan'    => 46,
		'white'      => 37,   'on_white'   => 47
	}


	###############
	module_function
	###############

	### Create a string that contains the ANSI codes specified and return it
	def ansi_code( *attributes )
		attributes.flatten!
		attributes.collect! {|at| at.to_s }

		return '' unless /(?:vt10[03]|xterm(?:-color)?|linux|screen)/i =~ ENV['TERM']
		attributes = ANSI_ATTRIBUTES.values_at( *attributes ).compact.join(';')

		# $stderr.puts "  attr is: %p" % [attributes]
		if attributes.empty?
			return ''
		else
			return "\e[%sm" % attributes
		end
	end


	### Colorize the given +string+ with the specified +attributes+ and return it, handling
	### line-endings, color reset, etc.
	def colorize( *args )
		string = ''

		if block_given?
			string = yield
		else
			string = args.shift
		end

		ending = string[/(\s)$/] || ''
		string = string.rstrip

		return ansi_code( args.flatten ) + string + ansi_code( 'reset' ) + ending
	end


	### Output a message with highlighting.
	def message( *msg )
		$stderr.puts( colorize(:bold) { msg.flatten.join(' ') } )
	end


	### Output a logging message if $VERBOSE is true
	def trace( *msg )
		return unless $VERBOSE
		output = colorize( msg.flatten.join(' '), 'yellow' )
		$stderr.puts( output )
	end


	### Return the specified args as a string, quoting any that have a space.
	def quotelist( *args )
		return args.flatten.collect {|part| part.to_s =~ /\s/ ? part.to_s.inspect : part.to_s }
	end


	### Run the specified command +cmd+ with system(), failing if the execution
	### fails.
	def run( *cmd )
		cmd.flatten!

		if cmd.length > 1
			trace( quotelist(*cmd) )
		else
			trace( cmd )
		end

		system( *cmd )
		raise "Command failed: [%s]" % [cmd.join(' ')] unless $?.success?
	end


	### Run the specified command +cmd+ after redirecting stdout and stderr to the specified
	### +logpath+, failing if the execution fails.
	def log_and_run( logpath, *cmd )
		cmd.flatten!

		if cmd.length > 1
			trace( quotelist(*cmd) )
		else
			trace( cmd )
		end

		# Eliminate the noise of creating/tearing down the database by
		# redirecting STDERR/STDOUT to a logfile
		logfh = File.open( logpath, File::WRONLY|File::CREAT|File::APPEND )
		system( *cmd, [STDOUT, STDERR] => logfh )

		raise "Command failed: [%s]" % [cmd.join(' ')] unless $?.success?
	end


	### Check the current directory for directories that look like they're
	### testing directories from previous tests, and tell any postgres instances
	### running in them to shut down.
	def stop_existing_postmasters
		# tmp_test_0.22329534700318
		pat = Pathname.getwd + 'tmp_test_*'
		Pathname.glob( pat.to_s ).each do |testdir|
			datadir = testdir + 'data'
			pidfile = datadir + 'postmaster.pid'
			if pidfile.exist? && pid = pidfile.read.chomp.to_i
				$stderr.puts "pidfile (%p) exists: %d" % [ pidfile, pid ]
				begin
					Process.kill( 0, pid )
				rescue Errno::ESRCH
					$stderr.puts "No postmaster running for %s" % [ datadir ]
					# Process isn't alive, so don't try to stop it
				else
					$stderr.puts "Stopping lingering database at PID %d" % [ pid ]
					run 'pg_ctl', '-D', datadir.to_s, '-m', 'fast', 'stop'
				end
			else
				$stderr.puts "No pidfile (%p)" % [ pidfile ]
			end
		end
	end


	### Set up a PostgreSQL database instance for testing.
	def setup_testing_db( description )
		require 'pg'
		stop_existing_postmasters()

		puts "Setting up test database for #{description}"
		@test_pgdata = TEST_DIRECTORY + 'data'
		@test_pgdata.mkpath

		@port = 54321
		ENV['PGPORT'] = @port.to_s
		ENV['PGHOST'] = 'localhost'
		@conninfo = "host=localhost port=#{@port} dbname=test"

		@logfile = TEST_DIRECTORY + 'setup.log'
		trace "Command output logged to #{@logfile}"

		begin
			unless (@test_pgdata+"postgresql.conf").exist?
				FileUtils.rm_rf( @test_pgdata, :verbose => $DEBUG )
				$stderr.puts "Running initdb"
				log_and_run @logfile, 'initdb', '-E', 'UTF8', '--no-locale', '-D', @test_pgdata.to_s
			end

			trace "Starting postgres"
			log_and_run @logfile, 'pg_ctl', '-w', '-o', "-k #{TEST_DIRECTORY.to_s.dump}",
				'-D', @test_pgdata.to_s, 'start'
			sleep 2

			$stderr.puts "Creating the test DB"
			log_and_run @logfile, 'psql', '-e', '-c', 'DROP DATABASE IF EXISTS test', 'postgres'
			log_and_run @logfile, 'createdb', '-e', 'test'

		rescue => err
			$stderr.puts "%p during test setup: %s" % [ err.class, err.message ]
			$stderr.puts "See #{@logfile} for details."
			$stderr.puts *err.backtrace if $DEBUG
			fail
		end

		conn = PG.connect( @conninfo )
		conn.set_notice_processor do |message|
			$stderr.puts( description + ':' + message ) if $DEBUG
		end

		return conn
	end


	def teardown_testing_db( conn )
		puts "Tearing down test database"

		if conn
			check_for_lingering_connections( conn )
			conn.finish
		end

		log_and_run @logfile, 'pg_ctl', '-D', @test_pgdata.to_s, 'stop'
	end


	def check_for_lingering_connections( conn )
		conn.exec( "SELECT * FROM pg_stat_activity" ) do |res|
			conns = res.find_all {|row| row['pid'].to_i != conn.backend_pid }
			unless conns.empty?
				puts "Lingering connections remain:"
				conns.each do |row|
					puts "  [%s] {%s} %s -- %s" % row.values_at( 'pid', 'state', 'application_name', 'query' )
				end
			end
		end
	end


	# Retrieve the names of the column types of a given result set.
	def result_typenames(res)
		@conn.exec( "SELECT " + res.nfields.times.map{|i| "format_type($#{i*2+1},$#{i*2+2})"}.join(","),
				res.nfields.times.map{|i| [res.ftype(i), res.fmod(i)] }.flatten ).
				values[0]
	end


	# A matcher for checking the status of a PG::Connection to ensure it's still
	# usable.
	class ConnStillUsableMatcher

		def initialize
			@conn = nil
			@problem = nil
		end

		def matches?( conn )
			@conn = conn
			@problem = self.check_for_problems
			return @problem.nil?
		end

		def check_for_problems
			return "is finished" if @conn.finished?
			return "has bad status" unless @conn.status == PG::CONNECTION_OK
			return "has bad transaction status (%d)" % [ @conn.transaction_status ] unless
				@conn.transaction_status.between?( PG::PQTRANS_IDLE, PG::PQTRANS_INTRANS )
			return "is not usable." unless self.can_exec_query?
			return nil
		end

		def can_exec_query?
			@conn.send_query( "VALUES (1)" )
			@conn.get_last_result.values == [["1"]]
		end

		def failure_message
			return "expected %p to be usable, but it %s" % [ @conn, @problem ]
		end

		def failure_message_when_negated
			"expected %p not to be usable, but it still is" % [ @conn ]
		end

	end


	### Return a ConnStillUsableMatcher to be used like:
	###
	###    expect( pg_conn ).to still_be_usable
	###
	def still_be_usable
		return ConnStillUsableMatcher.new
	end

end


RSpec.configure do |config|
	config.include( PG::TestingHelpers )

	config.run_all_when_everything_filtered = true
	config.filter_run :focus
	config.order = 'random'
	config.mock_with( :rspec ) do |mock|
		mock.syntax = :expect
	end

	if RUBY_PLATFORM =~ /mingw|mswin/
		config.filter_run_excluding :unix
	else
		config.filter_run_excluding :windows
	end
	config.filter_run_excluding :socket_io unless
		PG::Connection.instance_methods.map( &:to_sym ).include?( :socket_io )

	if PG.library_version < 90200
		config.filter_run_excluding( :postgresql_92, :postgresql_93, :postgresql_94, :postgresql_95 )
	elsif PG.library_version < 90300
		config.filter_run_excluding( :postgresql_93, :postgresql_94, :postgresql_95 )
	elsif PG.library_version < 90400
		config.filter_run_excluding( :postgresql_94, :postgresql_95 )
	elsif PG.library_version < 90500
		config.filter_run_excluding( :postgresql_95 )
	end
end

