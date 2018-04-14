#!/usr/bin/env ruby

require 'rubygems'
require 'pathname'
$basedir = Pathname.new(__FILE__).dirname.parent
$LOAD_PATH.unshift $basedir + 'lib'
require 'domain_name'
require 'set'
require 'erb'

def main
  dat_file = $basedir + 'data' + 'public_suffix_list.dat'
  dir      = $basedir + 'lib' + 'domain_name'
  erb_file = dir + 'etld_data.rb.erb'
  rb_file  = dir + 'etld_data.rb'

  etld_data_date = File.mtime(dat_file)

  File.open(dat_file, 'r:utf-8') { |dat|
    etld_data = parse(dat)
    File.open(rb_file, 'w:utf-8') { |rb|
      File.open(erb_file, 'r:utf-8') { |erb|
        rb.print ERB.new(erb.read).result(binding)
      }
    }
  }
end

def normalize_hostname(domain)
  DomainName.normalize(domain)
end

def parse(f)
  {}.tap { |table|
    tlds = Set[]
    f.each_line { |line|
      line.sub!(%r{//.*}, '')
      line.strip!
      next if line.empty?
      case line
      when /^local$/
        # ignore .local
        next
      when /^([^!*]+)$/
        domain = normalize_hostname($1)
        value = 0
      when /^\*\.([^!*]+)$/
        domain = normalize_hostname($1)
        value = -1
      when /^\!([^!*]+)$/
        domain = normalize_hostname($1)
        value = 1
      else
        raise "syntax error: #{line}"
      end
      tld = domain.match(/(?:^|\.)([^.]+)$/)[1]
      table[tld] ||= 1
      table[domain] = value
    }
  }
end

main()
