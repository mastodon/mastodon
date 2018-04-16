require 'pp'
require 'mkmf'


if ENV['MAINTAINER_MODE']
	$stderr.puts "Maintainer mode enabled."
	$CFLAGS <<
		' -Wall' <<
		' -ggdb' <<
		' -DDEBUG' <<
		' -pedantic'
end

if pgdir = with_config( 'pg' )
	ENV['PATH'] = "#{pgdir}/bin" + File::PATH_SEPARATOR + ENV['PATH']
end

if enable_config("windows-cross")
	# Avoid dependency to external libgcc.dll on x86-mingw32
	$LDFLAGS << " -static-libgcc"
	# Don't use pg_config for cross build, but --with-pg-* path options
	dir_config 'pg'

else
	# Native build

	pgconfig = with_config('pg-config') ||
		with_config('pg_config') ||
		find_executable('pg_config')

	if pgconfig && pgconfig != 'ignore'
		$stderr.puts "Using config values from %s" % [ pgconfig ]
		incdir = `"#{pgconfig}" --includedir`.chomp
		libdir = `"#{pgconfig}" --libdir`.chomp
		dir_config 'pg', incdir, libdir

		# Try to use runtime path linker option, even if RbConfig doesn't know about it.
		# The rpath option is usually set implicit by dir_config(), but so far not
		# on MacOS-X.
		if RbConfig::CONFIG["RPATHFLAG"].to_s.empty? && try_link('int main() {return 0;}', " -Wl,-rpath,#{libdir}")
			$LDFLAGS << " -Wl,-rpath,#{libdir}"
		end
	else
		$stderr.puts "No pg_config... trying anyway. If building fails, please try again with",
			" --with-pg-config=/path/to/pg_config"
		dir_config 'pg'
	end
end

if RUBY_VERSION >= '2.3.0' && /solaris/ =~ RUBY_PLATFORM
	append_cppflags( '-D__EXTENSIONS__' )
end

find_header( 'libpq-fe.h' ) or abort "Can't find the 'libpq-fe.h header"
find_header( 'libpq/libpq-fs.h' ) or abort "Can't find the 'libpq/libpq-fs.h header"
find_header( 'pg_config_manual.h' ) or abort "Can't find the 'pg_config_manual.h' header"

abort "Can't find the PostgreSQL client library (libpq)" unless
	have_library( 'pq', 'PQconnectdb', ['libpq-fe.h'] ) ||
	have_library( 'libpq', 'PQconnectdb', ['libpq-fe.h'] ) ||
	have_library( 'ms/libpq', 'PQconnectdb', ['libpq-fe.h'] )

# optional headers/functions
have_func 'PQconnectionUsedPassword' or
	abort "Your PostgreSQL is too old. Either install an older version " +
	      "of this gem or upgrade your database."
have_func 'PQisthreadsafe'
have_func 'PQprepare'
have_func 'PQexecParams'
have_func 'PQescapeString'
have_func 'PQescapeStringConn'
have_func 'PQescapeLiteral'
have_func 'PQescapeIdentifier'
have_func 'PQgetCancel'
have_func 'lo_create'
have_func 'pg_encoding_to_char'
have_func 'pg_char_to_encoding'
have_func 'PQsetClientEncoding'
have_func 'PQlibVersion'
have_func 'PQping'
have_func 'PQsetSingleRowMode'
have_func 'PQconninfo'
have_func 'PQsslAttribute'

have_func 'rb_encdb_alias'
have_func 'rb_enc_alias'
have_func 'rb_thread_call_without_gvl'
have_func 'rb_thread_call_with_gvl'
have_func 'rb_thread_fd_select'
have_func 'rb_w32_wrap_io_handle'
have_func 'rb_str_modify_expand'
have_func 'rb_hash_dup'

have_const 'PGRES_COPY_BOTH', 'libpq-fe.h'
have_const 'PGRES_SINGLE_TUPLE', 'libpq-fe.h'
have_const 'PG_DIAG_TABLE_NAME', 'libpq-fe.h'

$defs.push( "-DHAVE_ST_NOTIFY_EXTRA" ) if
	have_struct_member 'struct pgNotify', 'extra', 'libpq-fe.h'

# unistd.h confilicts with ruby/win32.h when cross compiling for win32 and ruby 1.9.1
have_header 'unistd.h'
have_header 'inttypes.h'
have_header 'ruby/st.h' or have_header 'st.h' or abort "pg currently requires the ruby/st.h header"

checking_for "C99 variable length arrays" do
	$defs.push( "-DHAVE_VARIABLE_LENGTH_ARRAYS" ) if try_compile('void test_vla(int l){ int vla[l]; }')
end

create_header()
create_makefile( "pg_ext" )

