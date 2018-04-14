require 'bundler/gem_tasks'
require 'uri'
ETLD_DATA_URI  = URI('https://publicsuffix.org/list/public_suffix_list.dat')
ETLD_DATA_FILE = 'data/public_suffix_list.dat'
ETLD_DATA_RB   = 'lib/domain_name/etld_data.rb'
VERSION_RB     = 'lib/domain_name/version.rb'

task :default => :test

task :test => ETLD_DATA_RB

task :import => :etld_data

#
# eTLD Database
#

task :etld_data do
  require 'open-uri'
  require 'time'

  begin
    begin
      load File.join('.', ETLD_DATA_RB)
      data = ETLD_DATA_URI.read(
        'If-Modified-Since' => Time.parse(DomainName::ETLD_DATA_DATE).rfc2822
      )
    rescue LoadError, NameError
      data = ETLD_DATA_URI.read
    end
    puts 'eTLD database is modified.'
    date = data.last_modified
    File.write(ETLD_DATA_FILE, data)
    File.utime Time.now, date, ETLD_DATA_FILE
    if new_version = DomainName::VERSION.dup.sub!(/\b\d{8}\b/, date.strftime('%Y%m%d'))
      File.open(VERSION_RB, 'r+') { |rb|
        content = rb.read
        rb.rewind
        rb.write(content.sub(/(?<=^  VERSION = ')#{Regexp.quote(DomainName::VERSION)}(?='$)/, new_version))
        rb.truncate(rb.tell)
      }
    end
    Rake::Task[ETLD_DATA_RB].execute
  rescue OpenURI::HTTPError => e
    if e.io.status.first == '304' # Not Modified
      puts 'eTLD database is up-to-date.'
    else
      raise
    end
  end
end

namespace :etld_data do
  task :commit do
    load ETLD_DATA_RB

    sh 'git', 'commit',
      ETLD_DATA_FILE,
      ETLD_DATA_RB,
      VERSION_RB,
      '-m', 'Update the eTLD database to %s.' % DomainName::ETLD_DATA_DATE
  end
end

file ETLD_DATA_RB => [
  ETLD_DATA_FILE,
  ETLD_DATA_RB + '.erb',
  'tool/gen_etld_data.rb'
] do
  ruby 'tool/gen_etld_data.rb'
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = DomainName::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "domain_name #{version}"
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include(Bundler::GemHelper.gemspec.extra_rdoc_files)
end
