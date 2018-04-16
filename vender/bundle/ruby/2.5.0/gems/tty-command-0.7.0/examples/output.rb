# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new
cmd.run("i=0; while true; do i=$[$i+1]; echo 'hello '$i; sleep 1; done") do |out, err|
  if out =~ /.*5.*/
    raise ArgumentError, 'BOOM'
  end
end
