# This file implements a simple consistency test for Redis-rb (or any other
# Redis environment if you pass a different client object) where a client
# writes to the database using INCR in order to increment keys, but actively
# remember the value the key should have. Before every write a read is performed
# to check if the value in the database matches the value expected.
#
# In this way this program can check for lost writes, or acknowledged writes
# that were executed.
#
# Copyright (C) 2013-2014 Salvatore Sanfilippo <antirez@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'redis'

class ConsistencyTester
    def initialize(redis)
        @r = redis
        @working_set = 10000
        @keyspace = 100000
        @writes = 0
        @reads = 0
        @failed_writes = 0
        @failed_reads = 0
        @lost_writes = 0
        @not_ack_writes = 0
        @delay = 0
        @cached = {} # We take our view of data stored in the DB.
        @prefix = [Process.pid.to_s,Time.now.usec,@r.object_id,""].join("|")
        @errtime = {}
    end

    def genkey
        # Write more often to a small subset of keys
        ks = rand() > 0.5 ? @keyspace : @working_set
        @prefix+"key_"+rand(ks).to_s
    end

    def check_consistency(key,value)
        expected = @cached[key]
        return if !expected  # We lack info about previous state.
        if expected > value
            @lost_writes += expected-value
        elsif expected < value
            @not_ack_writes += value-expected
        end
    end

    def puterr(msg)
        if !@errtime[msg] || Time.now.to_i != @errtime[msg]
            puts msg
        end
        @errtime[msg] = Time.now.to_i
    end

    def test
        last_report = Time.now.to_i
        while true
            # Read
            key = genkey
            begin
                val = @r.get(key)
                check_consistency(key,val.to_i)
                @reads += 1
            rescue => e
                puterr "Reading: #{e.class}: #{e.message} (#{e.backtrace.first})"
                @failed_reads += 1
            end

            # Write
            begin
                @cached[key] = @r.incr(key).to_i
                @writes += 1
            rescue => e
                puterr "Writing: #{e.class}: #{e.message} (#{e.backtrace.first})"
                @failed_writes += 1
            end

            # Report
            sleep @delay
            if Time.now.to_i != last_report
                report = "#{@reads} R (#{@failed_reads} err) | " +
                         "#{@writes} W (#{@failed_writes} err) | "
                report += "#{@lost_writes} lost | " if @lost_writes > 0
                report += "#{@not_ack_writes} noack | " if @not_ack_writes > 0
                last_report = Time.now.to_i
                puts report
            end
        end
    end
end

Sentinels = [{:host => "127.0.0.1", :port => 26379},
             {:host => "127.0.0.1", :port => 26380}]
r = Redis.new(:url => "redis://master1", :sentinels => Sentinels, :role => :master)
tester = ConsistencyTester.new(r)
tester.test
