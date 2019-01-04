# frozen_string_literal: true

class Form::Migration
  include ActiveModel::Validations

  attr_accessor :acct, :account

  def initialize(attrs = {})
    @account = attrs[:account]
    @acct    = attrs[:account].acct unless @account.nil?
    @acct    = attrs[:acct].gsub(/\A@/, '').strip unless attrs[:acct].nil?
  end

  def valid?
    return false unless super
    set_account
    errors.empty?
  end

  private

  def set_account
    self.account = (ResolveAccountService.new.call(acct) if account.nil? && acct.present?)
  end
end
