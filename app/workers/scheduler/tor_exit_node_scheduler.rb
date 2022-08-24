# frozen_string_literal: true

class Scheduler::TorExitNodeScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  CHECK_URL = 'https://check.torproject.org/torbulkexitlist'

  def perform
    grab_exit_addresses!
    add_exit_addresses!
  end

  def grab_exit_addresses!
    Request.new(:get, CHECK_URL).perform do |res|
      @ips = res.body
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
        comment: 'Tor exit node',
        expires_in: 24.hours.to_i
      )
    end
  end
end
