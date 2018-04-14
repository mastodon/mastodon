# :markup: markdown
require 'http/cookie_jar'
require 'sqlite3'

class HTTP::CookieJar
  # A store class that uses Mozilla compatible SQLite3 database as
  # backing store.
  #
  # Session cookies are stored separately on memory and will not be
  # stored persistently in the SQLite3 database.
  class MozillaStore < AbstractStore
    # :stopdoc:
    SCHEMA_VERSION = 5

    def default_options
      {
        :gc_threshold => HTTP::Cookie::MAX_COOKIES_TOTAL / 20,
        :app_id => 0,
        :in_browser_element => false,
      }
    end

    ALL_COLUMNS = %w[
      baseDomain
      appId inBrowserElement
      name value
      host path
      expiry creationTime lastAccessed
      isSecure isHttpOnly
    ]
    UK_COLUMNS = %w[
      name host path
      appId inBrowserElement
    ]

    SQL = {}

    Callable = proc { |obj, meth, *args|
      proc {
        obj.__send__(meth, *args)
      }
    }

    class Database < SQLite3::Database
      def initialize(file, options = {})
        @stmts = []
        options = {
          :results_as_hash => true,
        }.update(options)
        super
      end

      def prepare(sql)
        case st = super
        when SQLite3::Statement
          @stmts << st
        end
        st
      end

      def close
        return self if closed?
        @stmts.reject! { |st|
          st.closed? || st.close
        }
        super
      end
    end
    # :startdoc:

    # :call-seq:
    #   new(**options)
    #
    # Generates a Mozilla cookie store.  If the file does not exist,
    # it is created.  If it does and its schema is old, it is
    # automatically upgraded with a new schema keeping the existing
    # data.
    #
    # Available option keywords are as below:
    #
    # :filename
    # : A file name of the SQLite3 database to open.  This option is
    # mandatory.
    #
    # :gc_threshold
    # : GC threshold; A GC happens when this many times cookies have
    # been stored (default: `HTTP::Cookie::MAX_COOKIES_TOTAL / 20`)
    #
    # :app_id
    # : application ID (default: `0`) to have per application jar.
    #
    # :in_browser_element
    # : a flag to tell if cookies are stored in an in browser
    # element. (default: `false`)
    def initialize(options = nil)
      super

      @filename = options[:filename] or raise ArgumentError, ':filename option is missing'

      @sjar = HTTP::CookieJar::HashStore.new

      @db = Database.new(@filename)

      @stmt = Hash.new { |st, key|
        st[key] = @db.prepare(SQL[key])
      }

      ObjectSpace.define_finalizer(self, Callable[@db, :close])

      upgrade_database

      @gc_index = 0
    end

    # Raises TypeError.  Cloning is inhibited in this store class.
    def initialize_copy(other)
      raise TypeError, 'can\'t clone %s' % self.class
    end

    # The file name of the SQLite3 database given in initialization.
    attr_reader :filename

    # Closes the SQLite3 database.  After closing, any operation may
    # raise an error.
    def close
      @db.closed? || @db.close
      self
    end

    # Tests if the SQLite3 database is closed.
    def closed?
      @db.closed?
    end

    # Returns the schema version of the database.
    def schema_version
      @schema_version ||= @db.execute("PRAGMA user_version").first[0]
    rescue SQLite3::SQLException
      @logger.warn "couldn't get schema version!" if @logger
      return nil
    end

    protected

    def schema_version= version
      @db.execute("PRAGMA user_version = %d" % version)
      @schema_version = version
    end

    def create_table
      self.schema_version = SCHEMA_VERSION
      @db.execute("DROP TABLE IF EXISTS moz_cookies")
      @db.execute(<<-'SQL')
                   CREATE TABLE moz_cookies (
                     id INTEGER PRIMARY KEY,
                     baseDomain TEXT,
                     appId INTEGER DEFAULT 0,
                     inBrowserElement INTEGER DEFAULT 0,
                     name TEXT,
                     value TEXT,
                     host TEXT,
                     path TEXT,
                     expiry INTEGER,
                     lastAccessed INTEGER,
                     creationTime INTEGER,
                     isSecure INTEGER,
                     isHttpOnly INTEGER,
                     CONSTRAINT moz_uniqueid UNIQUE (name, host, path, appId, inBrowserElement)
                   )
      SQL
      @db.execute(<<-'SQL')
                   CREATE INDEX moz_basedomain
                     ON moz_cookies (baseDomain,
                                     appId,
                                     inBrowserElement);
      SQL
    end

    def db_prepare(sql)
      st = @db.prepare(sql)
      yield st
    ensure
      st.close if st
    end

    def upgrade_database
      loop {
        case schema_version
        when nil, 0
          self.schema_version = SCHEMA_VERSION
          break
        when 1
          @db.execute("ALTER TABLE moz_cookies ADD lastAccessed INTEGER")
          self.schema_version += 1
        when 2
          @db.execute("ALTER TABLE moz_cookies ADD baseDomain TEXT")

          db_prepare("UPDATE moz_cookies SET baseDomain = :baseDomain WHERE id = :id") { |st_update|
            @db.execute("SELECT id, host FROM moz_cookies") { |row|
              domain_name = DomainName.new(row['host'][/\A\.?(.*)/, 1])
              domain = domain_name.domain || domain_name.hostname
              st_update.execute(:baseDomain => domain, :id => row['id'])
            }
          }

          @db.execute("CREATE INDEX moz_basedomain ON moz_cookies (baseDomain)")
          self.schema_version += 1
        when 3
          db_prepare("DELETE FROM moz_cookies WHERE id = :id") { |st_delete|
            prev_row = nil
            @db.execute(<<-'SQL') { |row|
                         SELECT id, name, host, path FROM moz_cookies
                           ORDER BY name ASC, host ASC, path ASC, expiry ASC
            SQL
              if %w[name host path].all? { |col| prev_row and row[col] == prev_row[col] }
                st_delete.execute(prev_row['id'])
              end
              prev_row = row
            }
          }

          @db.execute("ALTER TABLE moz_cookies ADD creationTime INTEGER")
          @db.execute("UPDATE moz_cookies SET creationTime = (SELECT id WHERE id = moz_cookies.id)")
          @db.execute("CREATE UNIQUE INDEX moz_uniqueid ON moz_cookies (name, host, path)")
          self.schema_version += 1
        when 4
          @db.execute("ALTER TABLE moz_cookies RENAME TO moz_cookies_old")
          @db.execute("DROP INDEX moz_basedomain")
          create_table
          @db.execute(<<-'SQL')
                       INSERT INTO moz_cookies
                         (baseDomain, appId, inBrowserElement, name, value, host, path, expiry,
                          lastAccessed, creationTime, isSecure, isHttpOnly)
                         SELECT baseDomain, 0, 0, name, value, host, path, expiry,
                                lastAccessed, creationTime, isSecure, isHttpOnly
                           FROM moz_cookies_old
          SQL
          @db.execute("DROP TABLE moz_cookies_old")
          @logger.info("Upgraded database to schema version %d" % schema_version) if @logger
        else
          break
        end
      }

      begin
        @db.execute("SELECT %s from moz_cookies limit 1" % ALL_COLUMNS.join(', '))
      rescue SQLite3::SQLException
        create_table
      end
    end

    SQL[:add] = <<-'SQL' % [
      INSERT OR REPLACE INTO moz_cookies (%s) VALUES (%s)
    SQL
      ALL_COLUMNS.join(', '),
      ALL_COLUMNS.map { |col| ":#{col}" }.join(', ')
    ]

    def db_add(cookie)
      @stmt[:add].execute({
          :baseDomain => cookie.domain_name.domain || cookie.domain,
          :appId => @app_id,
          :inBrowserElement => @in_browser_element ? 1 : 0,
          :name => cookie.name, :value => cookie.value,
          :host => cookie.dot_domain,
          :path => cookie.path,
          :expiry => cookie.expires_at.to_i,
          :creationTime => cookie.created_at.to_i,
          :lastAccessed => cookie.accessed_at.to_i,
          :isSecure => cookie.secure? ? 1 : 0,
          :isHttpOnly => cookie.httponly? ? 1 : 0,
        })
      cleanup if (@gc_index += 1) >= @gc_threshold

      self
    end

    SQL[:delete] = <<-'SQL'
      DELETE FROM moz_cookies
        WHERE appId = :appId AND
              inBrowserElement = :inBrowserElement AND
              name = :name AND
              host = :host AND
              path = :path
    SQL

    def db_delete(cookie)
      @stmt[:delete].execute({
          :appId => @app_id,
          :inBrowserElement => @in_browser_element ? 1 : 0,
          :name => cookie.name,
          :host => cookie.dot_domain,
          :path => cookie.path,
        })
      self
    end

    public

    def add(cookie)
      if cookie.session?
        @sjar.add(cookie)
        db_delete(cookie)
      else
        @sjar.delete(cookie)
        db_add(cookie)
      end
    end

    def delete(cookie)
      @sjar.delete(cookie)
      db_delete(cookie)
    end

    SQL[:cookies_for_domain] = <<-'SQL'
      SELECT * FROM moz_cookies
        WHERE baseDomain = :baseDomain AND
              appId = :appId AND
              inBrowserElement = :inBrowserElement AND
              expiry >= :expiry
    SQL

    SQL[:update_lastaccessed] = <<-'SQL'
      UPDATE moz_cookies
        SET lastAccessed = :lastAccessed
        WHERE id = :id
    SQL

    SQL[:all_cookies] = <<-'SQL'
      SELECT * FROM moz_cookies
        WHERE appId = :appId AND
              inBrowserElement = :inBrowserElement AND
              expiry >= :expiry
    SQL

    def each(uri = nil, &block) # :yield: cookie
      now = Time.now
      if uri
        thost = DomainName.new(uri.host)
        tpath = uri.path

        @stmt[:cookies_for_domain].execute({
            :baseDomain => thost.domain || thost.hostname,
            :appId => @app_id,
            :inBrowserElement => @in_browser_element ? 1 : 0,
            :expiry => now.to_i,
          }).each { |row|
          if secure = row['isSecure'] != 0
            next unless URI::HTTPS === uri
          end

          cookie = HTTP::Cookie.new({}.tap { |attrs|
              attrs[:name]        = row['name']
              attrs[:value]       = row['value']
              attrs[:domain]      = row['host']
              attrs[:path]        = row['path']
              attrs[:expires_at]  = Time.at(row['expiry'])
              attrs[:accessed_at] = Time.at(row['lastAccessed'] || 0)
              attrs[:created_at]  = Time.at(row['creationTime'] || 0)
              attrs[:secure]      = secure
              attrs[:httponly]    = row['isHttpOnly'] != 0
            })

          if cookie.valid_for_uri?(uri)
            cookie.accessed_at = now
            @stmt[:update_lastaccessed].execute({
                'lastAccessed' => now.to_i,
                'id' => row['id'],
              })
            yield cookie
          end
        }
        @sjar.each(uri, &block)
      else
        @stmt[:all_cookies].execute({
            :appId => @app_id,
            :inBrowserElement => @in_browser_element ? 1 : 0,
            :expiry => now.to_i,
          }).each { |row|
          cookie = HTTP::Cookie.new({}.tap { |attrs|
              attrs[:name]        = row['name']
              attrs[:value]       = row['value']
              attrs[:domain]      = row['host']
              attrs[:path]        = row['path']
              attrs[:expires_at]  = Time.at(row['expiry'])
              attrs[:accessed_at] = Time.at(row['lastAccessed'] || 0)
              attrs[:created_at]  = Time.at(row['creationTime'] || 0)
              attrs[:secure]      = row['isSecure'] != 0
              attrs[:httponly]    = row['isHttpOnly'] != 0
            })

          yield cookie
        }
        @sjar.each(&block)
      end
      self
    end

    def clear
      @db.execute("DELETE FROM moz_cookies")
      @sjar.clear
      self
    end

    SQL[:delete_expired] = <<-'SQL'
      DELETE FROM moz_cookies WHERE expiry < :expiry
    SQL

    SQL[:overusing_domains] = <<-'SQL'
      SELECT LTRIM(host, '.') domain, COUNT(*) count
        FROM moz_cookies
        GROUP BY domain
        HAVING count > :count
    SQL

    SQL[:delete_per_domain_overuse] = <<-'SQL'
      DELETE FROM moz_cookies WHERE id IN (
        SELECT id FROM moz_cookies
          WHERE LTRIM(host, '.') = :domain
          ORDER BY creationtime
          LIMIT :limit)
    SQL

    SQL[:delete_total_overuse] = <<-'SQL'
      DELETE FROM moz_cookies WHERE id IN (
        SELECT id FROM moz_cookies ORDER BY creationTime ASC LIMIT :limit
      )
    SQL

    def cleanup(session = false)
      synchronize {
        break if @gc_index == 0

        @stmt[:delete_expired].execute({ 'expiry' => Time.now.to_i })

        @stmt[:overusing_domains].execute({
            'count' => HTTP::Cookie::MAX_COOKIES_PER_DOMAIN
          }).each { |row|
          domain, count = row['domain'], row['count']

          @stmt[:delete_per_domain_overuse].execute({
              'domain' => domain,
              'limit' => count - HTTP::Cookie::MAX_COOKIES_PER_DOMAIN,
            })
        }

        overrun = count - HTTP::Cookie::MAX_COOKIES_TOTAL

        if overrun > 0
          @stmt[:delete_total_overuse].execute({ 'limit' => overrun })
        end

        @gc_index = 0
      }
      self
    end
  end
end
