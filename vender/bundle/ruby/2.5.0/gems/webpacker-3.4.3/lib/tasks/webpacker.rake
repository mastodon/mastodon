tasks = {
  "webpacker:install"                 => "Installs and setup webpack with Yarn",
  "webpacker:compile"                 => "Compiles webpack bundles based on environment",
  "webpacker:clobber"                 => "Removes the webpack compiled output directory",
  "webpacker:check_node"              => "Verifies if Node.js is installed",
  "webpacker:check_yarn"              => "Verifies if Yarn is installed",
  "webpacker:check_binstubs"          => "Verifies that webpack & webpack-dev-server are present",
  "webpacker:binstubs"                => "Installs Webpacker binstubs in this application",
  "webpacker:verify_install"          => "Verifies if Webpacker is installed",
  "webpacker:yarn_install"            => "Support for older Rails versions. Install all JavaScript dependencies as specified via Yarn",
  "webpacker:install:react"           => "Installs and setup example React component",
  "webpacker:install:vue"             => "Installs and setup example Vue component",
  "webpacker:install:angular"         => "Installs and setup example Angular component",
  "webpacker:install:elm"             => "Installs and setup example Elm component",
  "webpacker:install:stimulus"        => "Installs and setup example Stimulus component",
  "webpacker:install:erb"             => "Installs Erb loader with an example",
  "webpacker:install:coffee"          => "Installs CoffeeScript loader with an example",
  "webpacker:install:typescript"      => "Installs Typescript loader with an example"
}.freeze

desc "Lists all available tasks in Webpacker"
task :webpacker do
  puts "Available Webpacker tasks are:"
  tasks.each { |task, message| puts task.ljust(30) + message }
end
