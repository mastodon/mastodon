desc "Fetch upstream submodules"
task :submodules do
  if Dir['ext/ruby_http_parser/vendor/http-parser/*'].empty?
    sh 'git submodule init'
    sh 'git submodule update'
  end
end
