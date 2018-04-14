# -*- ruby encoding: utf-8 -*-

require 'rubygems'
require 'hoe'
require 'rake/clean'

Hoe.plugin :doofus
Hoe.plugin :gemspec2
Hoe.plugin :git
Hoe.plugin :minitest
Hoe.plugin :travis
Hoe.plugin :email unless ENV['CI'] or ENV['TRAVIS']

spec = Hoe.spec 'mime-types' do
  developer('Austin Ziegler', 'halostatue@gmail.com')
  self.need_tar = true

  require_ruby_version '>= 2.0'

  self.history_file = 'History.rdoc'
  self.readme_file = 'README.rdoc'

  license 'MIT'

  extra_deps << ['mime-types-data', '~> 3.2015']

  extra_dev_deps << ['hoe-doofus', '~> 1.0']
  extra_dev_deps << ['hoe-gemspec2', '~> 1.1']
  extra_dev_deps << ['hoe-git', '~> 1.6']
  extra_dev_deps << ['hoe-rubygems', '~> 1.0']
  extra_dev_deps << ['hoe-travis', '~> 1.2']
  extra_dev_deps << ['minitest', '~> 5.4']
  extra_dev_deps << ['minitest-autotest', '~> 1.0']
  extra_dev_deps << ['minitest-focus', '~> 1.0']
  extra_dev_deps << ['minitest-bonus-assertions', '~> 2.0']
  extra_dev_deps << ['minitest-hooks', '~> 1.4']
  extra_dev_deps << ['rake', '~> 10.0']
  extra_dev_deps << ['fivemat', '~> 1.3' ]
  extra_dev_deps << ['minitest-rg', '~> 5.2']

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.0')
    extra_dev_deps << ['simplecov', '~> 0.7']
    # if ENV['CI'] or ENV['TRAVIS']
    #   extra_dev_deps << ['coveralls', '~> 0.8']
    # end
  end
end

namespace :benchmark do
  task :support do
    %w(lib support).each { |path|
      $LOAD_PATH.unshift(File.join(Rake.application.original_dir, path))
    }
  end

  desc 'Benchmark Load Times'
  task :load, [ :repeats ] => 'benchmark:support' do |_, args|
    require 'benchmarks/load'
    Benchmarks::Load.report(
      File.join(Rake.application.original_dir, 'lib'),
      args.repeats
    )
  end

  desc 'Allocation counts'
  task :allocations, [ :top_x, :mime_types_only ] => 'benchmark:support' do |_, args|
    require 'benchmarks/load_allocations'
    Benchmarks::LoadAllocations.report(
      top_x: args.top_x,
      mime_types_only: args.mime_types_only
    )
  end

  desc 'Columnar allocation counts'
  task 'allocations:columnar', [ :top_x, :mime_types_only ] => 'benchmark:support' do |_, args|
    require 'benchmarks/load_allocations'
    Benchmarks::LoadAllocations.report(
      columnar: true,
      top_x: args.top_x,
      mime_types_only: args.mime_types_only
    )
  end

  desc 'Columnar allocation counts (full load)'
  task 'allocations:columnar:full', [ :top_x, :mime_types_only ] => 'benchmark:support' do |_, args|
    require 'benchmarks/load_allocations'
    Benchmarks::LoadAllocations.report(
      columnar: true,
      top_x: args.top_x,
      mime_types_only: args.mime_types_only,
      full: true
    )
  end

  desc 'Object counts'
  task objects: 'benchmark:support' do
    require 'benchmarks/object_counts'
    Benchmarks::ObjectCounts.report
  end

  desc 'Columnar object counts'
  task 'objects:columnar' => 'benchmark:support' do
    require 'benchmarks/object_counts'
    Benchmarks::ObjectCounts.report(columnar: true)
  end

  desc 'Columnar object counts (full load)'
  task 'objects:columnar:full' => 'benchmark:support' do
    require 'benchmarks/object_counts'
    Benchmarks::ObjectCounts.report(columnar: true, full: true)
  end
end

namespace :profile do
  directory 'tmp/profile'

  CLEAN.add 'tmp'

  def ruby_prof(script)
    require 'pathname'
    output = Pathname('tmp/profile').join(script)
    output.mkpath
    script = Pathname('support/profile').join("#{script}.rb")

    args = [
      '-W0',
      '-Ilib',
      '-S', 'ruby-prof',
      '-R', 'mime/types',
      '-s', 'self',
      '-p', 'multi',
      '-f', "#{output}",
      script.to_s
    ]
    ruby args.join(' ')
  end

  task full: 'tmp/profile' do
    ruby_prof 'full'
  end

  task columnar: :support do
    ruby_prof 'columnar'
  end

  task 'columnar:full' => :support do
    ruby_prof 'columnar_full'
  end
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.0')
  namespace :test do
    # Coveralls needs to be disabled for now because it transitively depends on
    # an earlier version of mime-types.
    # if ENV['CI'] or ENV['TRAVIS']
    #   task :coveralls do
    #     spec.test_prelude = [
    #       'require "psych"',
    #       'require "simplecov"',
    #       'require "coveralls"',
    #       'SimpleCov.formatter = Coveralls::SimpleCov::Formatter',
    #       'SimpleCov.start("test_frameworks") { command_name "Minitest" }',
    #       'gem "minitest"'
    #     ].join('; ')
    #     Rake::Task['test'].execute
    #   end

    #   Rake::Task['travis'].prerequisites.replace(%w(test:coveralls))
    # end

    desc 'Run test coverage'
    task :coverage do
      spec.test_prelude = [
        'require "simplecov"',
        'SimpleCov.start("test_frameworks") { command_name "Minitest" }',
        'gem "minitest"'
      ].join('; ')
      Rake::Task['test'].execute
    end
  end
end

namespace :convert do
  namespace :docs do
    task :setup do
      gem 'rdoc'
      require 'rdoc/rdoc'
      @doc_converter ||= RDoc::Markup::ToMarkdown.new
    end

    FileList['*.rdoc'].each do |name|
      rdoc = name
      mark = "#{File.basename(name, '.rdoc')}.md"

      file mark => [ rdoc, :setup ] do |t|
        puts "#{rdoc} => #{mark}"
        File.open(t.name, 'wb') { |target|
          target.write @doc_converter.convert(IO.read(t.prerequisites.first))
        }
      end

      CLEAN.add mark

      task run: [ mark ]
    end
  end

  desc 'Convert documentation from RDoc to Markdown'
  task docs: 'convert:docs:run'
end

task 'deps:top', [ :number ] do |_, args|
  require 'net/http'
  require 'json'

  def rubygems_get(gem_name: '', endpoint: '')
    path = File.join('/api/v1/gems/', gem_name, endpoint).chomp('/') + '.json'
    Net::HTTP.start('rubygems.org', use_ssl: true) do |http|
      JSON.parse(http.get(path).body)
    end
  end

  results = rubygems_get(
    gem_name: 'mime-types',
    endpoint: 'reverse_dependencies'
  )

  weighted_results = {}
  results.each do |name|
    begin
      weighted_results[name] = rubygems_get(gem_name: name)['downloads']
    rescue => e
      puts "#{name} #{e.message}"
    end
  end

  weighted_results.sort { |(_k1, v1), (_k2, v2)|
    v2 <=> v1
  }.first(args.number || 50).each_with_index do |(k, v), i|
    puts "#{i}) #{k}: #{v}"
  end
end

task :console do
  arguments = %w(pry)
  arguments.push(*spec.spec.require_paths.map { |dir| "-I#{dir}" })
  arguments.push("-r#{spec.spec.name.gsub('-', File::SEPARATOR)}")
  unless system(*arguments)
    error "Command failed: #{show_command}"
    abort
  end
end

# vim: syntax=ruby
