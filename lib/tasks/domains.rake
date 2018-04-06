# frozen_string_literal: true
require 'pry'
require 'net/https'
require 'json'

def check_severity(severity)
  if ![:silence, :suspend, :noop].include?(severity.to_sym)
    abort 'Invalid severity.  Valid options include silence,suspend or noop.'
  end
end

def block_domain(domain, severity, reject_media)
  puts "blocking #{domain}"
  domain_block = DomainBlock.new(domain: domain, severity: severity.to_sym, reject_media: reject_media)
  DomainBlockWorker.perform_async(domain_block.id) if domain_block.save
end

namespace :domains do
  desc 'Add a single domain to the block list'
  task :block, [:severity, :reject_media] => [:environment] do |_t, args|
    domain_args = args.with_defaults(severity: 'silence', reject_media: false)
    check_severity(domain_args[:severity])

    block_domain(domain_args[:domain], domain_args[:severity], domain_args[:reject_media])
  end

  desc 'Add a list of domains to the block list'
  task :block_list, [:json_file, :severity, :reject_media] => [:environment] do |_t, args|
    domain_args = args.with_defaults(json_file: 'https://raw.githubusercontent.com/usbsnowcrash/blockchain/master/blockchain.json',
                                     severity: 'silence', reject_media: false)
    check_severity(domain_args[:severity])
    uri = URI(domain_args[:json_file])
    response = Net::HTTP.get(uri)

    list = JSON.parse(response)
    list['instances'].each do |item|
      block_domain(item['domain'], domain_args[:severity], domain_args[:reject_media])
    end
  end
end
