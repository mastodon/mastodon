# frozen_string_literal: true

class Scheduler::IPBlocklistURLScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    if ENV['SCHEDULED_IPBLOCK_URLS'].present?
      @block_url = ENV['SCHEDULED_IPBLOCK_URLS']
      @blockips = []
      grab_ip_blocks_addresses!
      add_ip_blocks_addresses!
    end

    if ENV['SCHEDULED_IPLIMIT_URLS'].present?
      @limit_url = ENV['SCHEDULED_IPBLIMIT_URLS']
      @limitips = []
      grab_ip_limit_addresses!
      add_ip_limit_addresses!
    end
  end

  def grab_ip_blocks_addresses!
    @block_url.split(',').each do |url|
      Request.new(:get, url).perform do |res|
        @blockips.insert = res.body
      end
    end
  end

  def grab_ip_limit_addresses!
    @limit_url.split(',').each do |url|
      Request.new(:get, url).perform do |res|
        @limitips.insert = res.body
      end
    end
  end

  def add_ip_blocks_addresses!
    @blockips.each do |ip|
      ip_block = IpBlock.find_by(ip: ip)

      if ip_block.present?
        ip_block.update(expires_in: 24.hours.to_i)
        next
      end

      IpBlock.create(
        ip: ip,
        severity: :sign_up_block,
        comment: 'Scheduled IPBlock',
        expires_in: 24.hours.to_i
      )
    end
  end

  def add_ip_limit_addresses!
    @limitips.each do |ip|
      ip_limit = Iplimit.find_by(ip: ip)

      if ip_limit.present?
        ip_limit.update(expires_in: 24.hours.to_i)
        next
      end

      Iplimit.create(
        ip: ip,
        severity: :sign_up_requires_approval,
        comment: 'Scheduled IPLimit',
        expires_in: 24.hours.to_i
      )
    end
  end  

end
