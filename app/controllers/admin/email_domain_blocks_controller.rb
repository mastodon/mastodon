# frozen_string_literal: true

module Admin
  class EmailDomainBlocksController < BaseController
    before_action :set_email_domain_block, only: [:show, :destroy]

    def index
      authorize :email_domain_block, :index?
      @email_domain_blocks = EmailDomainBlock.where(parent_id: nil).includes(:children).order(id: :desc).page(params[:page])
    end

    def new
      authorize :email_domain_block, :create?
      @email_domain_block = EmailDomainBlock.new(domain: params[:_domain])
    end

    def create
      authorize :email_domain_block, :create?

      @email_domain_block = EmailDomainBlock.new(resource_params)

      if @email_domain_block.save
        log_action :create, @email_domain_block

        if @email_domain_block.with_dns_records?
          hostnames = []
          ips       = []

          Resolv::DNS.open do |dns|
            dns.timeouts = 5

            hostnames = dns.getresources(@email_domain_block.domain, Resolv::DNS::Resource::IN::MX).to_a.map { |e| e.exchange.to_s }

            ([@email_domain_block.domain] + hostnames).uniq.each do |hostname|
              ips.concat(dns.getresources(hostname, Resolv::DNS::Resource::IN::A).to_a.map { |e| e.address.to_s })
              ips.concat(dns.getresources(hostname, Resolv::DNS::Resource::IN::AAAA).to_a.map { |e| e.address.to_s })
            end
          end

          (hostnames + ips).each do |hostname|
            another_email_domain_block = EmailDomainBlock.new(domain: hostname, parent: @email_domain_block)
            log_action :create, another_email_domain_block if another_email_domain_block.save
          end
        end

        redirect_to admin_email_domain_blocks_path, notice: I18n.t('admin.email_domain_blocks.created_msg')
      else
        render :new
      end
    end

    def destroy
      authorize @email_domain_block, :destroy?
      @email_domain_block.destroy!
      log_action :destroy, @email_domain_block
      redirect_to admin_email_domain_blocks_path, notice: I18n.t('admin.email_domain_blocks.destroyed_msg')
    end

    private

    def set_email_domain_block
      @email_domain_block = EmailDomainBlock.find(params[:id])
    end

    def resource_params
      params.require(:email_domain_block).permit(:domain, :with_dns_records)
    end
  end
end
