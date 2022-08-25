# frozen_string_literal: true

class Scheduler::IPBlockURLScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  CHECK_URL = ENV['SCHEDULED_IPBLOCK_URLS']
  @ips = Array.new

  def perform
    grab_exit_addresses!
    add_exit_addresses!
  end

  def grab_exit_addresses!
    CHECK_URL.split(",").each do |URL|
      Request.new(:get, URL).perform do |res|
        @ips.insert = res.body
      end
    end    
  end

  def add_exit_addresses!
    @ips.each do |ip|
      ip_block = IpBlock.find_by(ip: ip)

      if ip_block.present?
        ip_block.update(expires_in: 24.hours.to_i)
        next
      end

      IpBlock.create(
        ip: ip,
        severity: :sign_up_requires_approval,
        comment: 'Scheduled IPBlock',
        expires_in: 24.hours.to_i
      )
    end
  end
end
