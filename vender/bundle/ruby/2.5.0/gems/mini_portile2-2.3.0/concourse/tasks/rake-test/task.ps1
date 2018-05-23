. "nokogiri-ci\concourse\shared\common.ps1"
. "c:\var\vcap\packages\windows-ruby-dev-tools\prelude.ps1"

prepend-path $ruby23_bin_path
$env:RUBYOPT = "-rdevkit"

push-location mini_portile

    stream-cmd "gem" "install bundler"
    stream-cmd "bundle" "install"
    stream-cmd "bundle" "exec rake test"

pop-location
