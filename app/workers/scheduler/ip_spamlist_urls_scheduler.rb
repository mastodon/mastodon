# frozen_string_literal: true

class Scheduler::IpSpamlistUrlsScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    grab_ip_blocks_addresses! if ENV['SCHEDULED_IPBLOCK_URLS'].present?
    add_ip_blocks_addresses! if ENV['SCHEDULED_IPBLOCK_URLS'].present?
    grab_ip_limit_addresses! if ENV['SCHEDULED_IPLIMIT_URLS'].present?
    add_ip_limit_addresses! if ENV['SCHEDULED_IPLIMIT_URLS'].present?
  end

  def grab_ip_blocks_addresses!
    @blockips = []
    ENV['SCHEDULED_IPBLOCK_URLS'].split(',').each do |url|
      Request.new(:get, url).perform do |res|
        @blockips.insert = res.body
      end
    end
  end

  def grab_ip_limit_addresses!
    @limitips = []
    ENV['SCHEDULED_IPBLIMIT_URLS'].split(',').each do |url|
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
      ip_limit = IpBlock.find_by(ip: ip)

      if ip_limit.present?
        ip_limit.update(expires_in: 24.hours.to_i)
        next
      end

      IpBlock.create(
        ip: ip,
        severity: :sign_up_requires_approval,
        comment: 'Scheduled IPLimit',
        expires_in: 24.hours.to_i
      )
    end
  end
end
