require 'yard'
YARD::Rake::YardocTask.new

root = File.expand_path File.join(File.dirname(__FILE__), '..')

namespace :yard do

  cmd = lambda do |command|
    puts ">> executing: #{command}"
    system command or raise "#{command} failed"
  end

  desc 'Pushes generated documentation to github pages: http://ruby-concurrency.github.io/thread_safe/'
  task :push => [:setup, :yard] do

    message = Dir.chdir(root) do
      `git log -n 1 --oneline`.strip
    end
    puts "Generating commit: #{message}"

    Dir.chdir "#{root}/yardoc" do
      cmd.call "git add -A"
      cmd.call "git commit -m '#{message}'"
      cmd.call 'git push origin gh-pages'
    end

  end

  desc 'Setups second clone in ./yardoc dir for pushing doc to github'
  task :setup do

    unless File.exist? "#{root}/yardoc/.git"
      cmd.call "rm -rf #{root}/yardoc" if File.exist?("#{root}/yardoc")
      Dir.chdir "#{root}" do
        cmd.call 'git clone --single-branch --branch gh-pages git@github.com:ruby-concurrency/thread_safe.git ./yardoc'
      end
    end
    Dir.chdir "#{root}/yardoc" do
      cmd.call 'git fetch origin'
      cmd.call 'git reset --hard origin/gh-pages'
    end

  end

end
