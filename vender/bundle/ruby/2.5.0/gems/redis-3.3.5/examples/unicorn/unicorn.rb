require "redis"

worker_processes 3

# If you set the connection to Redis *before* forking,
# you will cause forks to share a file descriptor.
#
# This causes a concurrency problem by which one fork
# can read or write to the socket while others are
# performing other operations.
#
# Most likely you'll be getting ProtocolError exceptions
# mentioning a wrong initial byte in the reply.
#
# Thus we need to connect to Redis after forking the
# worker processes.

after_fork do |server, worker|
  Redis.current.disconnect!
end
