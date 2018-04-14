#!/usr/bin/env ruby

module Tags
  extend Rake::DSL if defined?(Rake::DSL)

  PROG = ENV['TAGS'] || 'ctags'

  RAKEFILES = FileList['Rakefile', '**/*.rake']

  FILES = FileList['**/*.rb', '**/*.js'] + RAKEFILES
  FILES.exclude('pkg', 'dist')

  PROJECT_DIR = ['.']

  RVM_GEMDIR = File.join(`rvm gemdir`.strip, "gems") rescue nil
  SYSTEM_DIRS = RVM_GEMDIR && File.exists?(RVM_GEMDIR) ? RVM_GEMDIR : []

  module_function

  # Convert key_word to --key-word.
  def keyword(key)
    k = key.to_s.gsub(/_/, '-')
    (k.length == 1) ? "-#{k}" : "--#{k}"
  end

  # Run ctags command
  def run(*args)
    opts = {
      :e => true,
      :totals => true,
      :recurse => true,
    }
    opts = opts.merge(args.pop) if args.last.is_a?(Hash)
    command_args = opts.map { |k, v|
      (v == true) ? keyword(k) : "#{keyword(k)}=#{v}"
    }.join(" ")
    sh %{#{Tags::PROG} #{command_args} #{args.join(' ')}}
  end
end

namespace "tags" do
  desc "Generate an Emacs TAGS file"
   task :emacs, [:all] => Tags::FILES do |t, args|
    puts "Making Emacs TAGS file"
    verbose(true) do
      Tags.run(Tags::PROJECT_DIR)
      Tags.run(Tags::RAKEFILES,
        :language_force => "ruby",
        :append => true)
      if args.all
        Tags::SYSTEM_DIRS.each do |dir|
          Tags.run(dir,
            :language_force => "ruby",
            :append => true)
        end
      end
    end
  end
end

desc "Generate the TAGS file"
task :tags, [:all] => ["tags:emacs"]
