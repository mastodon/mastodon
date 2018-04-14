require 'tty-command'

cmd = TTY::Command.new

threads = []
3.times do |i|
  th = Thread.new do
    10.times { cmd.run("echo th#{i}; sleep 0.1") }
  end
  threads << th
end
threads.each(&:join)
