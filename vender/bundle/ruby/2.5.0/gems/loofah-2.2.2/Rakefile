require 'rubygems'
gem 'hoe', '>= 2.3.0'
require 'hoe'
require 'concourse'

Hoe.plugin :git
Hoe.plugin :gemspec
Hoe.plugin :bundler
Hoe.plugin :debugging

Hoe.spec "loofah" do
  developer "Mike Dalessio", "mike.dalessio@gmail.com"
  developer "Bryan Helmkamp", "bryan@brynary.com"

  self.extra_rdoc_files = FileList["*.md"]
  self.history_file     = "CHANGELOG.md"
  self.readme_file      = "README.md"
  self.license          "MIT"

  extra_deps     << ["nokogiri", ">=1.5.9"]
  extra_deps     << ["crass", "~> 1.0.2"]

  extra_dev_deps << ["rake", ">=0.8"]
  extra_dev_deps << ["minitest", "~>2.2"]
  extra_dev_deps << ["rr", "~>1.2.0"]
  extra_dev_deps << ["json", ">=0"]
  extra_dev_deps << ["hoe-gemspec", ">=0"]
  extra_dev_deps << ["hoe-debugging", ">=0"]
  extra_dev_deps << ["hoe-bundler", ">=0"]
  extra_dev_deps << ["hoe-git", ">=0"]
  extra_dev_deps << ["concourse", ">=0.15.0"]
end

task :gemspec do
  system %q(rake debug_gem | grep -v "^\(in " > loofah.gemspec)
end

task :redocs => :fix_css
task :docs => :fix_css
task :fix_css do
  better_css = <<-EOT
    .method-description pre {
      margin                    : 1em 0 ;
    }

    .method-description ul {
      padding                   : .5em 0 .5em 2em ;
    }

    .method-description p {
      margin-top                : .5em ;
    }

    #main ul, div#documentation ul {
      list-style-type           : disc ! IMPORTANT ;
      list-style-position       : inside ! IMPORTANT ;
    }

    h2 + ul {
      margin-top                : 1em;
    }
  EOT
  puts "* fixing css"
  File.open("doc/rdoc.css", "a") { |f| f.write better_css }
end

desc "generate and upload docs to rubyforge"
task :doc_upload_to_rubyforge => :docs do
  Dir.chdir "doc" do
    system "rsync -avz --delete * rubyforge.org:/var/www/gforge-projects/loofah/loofah"
  end
end

desc "generate whitelists from W3C specifications"
task :generate_whitelists do
  load "tasks/generate-whitelists"
end

Concourse.new("loofah").create_tasks!
