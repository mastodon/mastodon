# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  layout 'plain_mailer'

  helper :accounts

  def new_report(recipient, report)
    @report   = report
    @me       = recipient
    @instance = Rails.configuration.x.local_domain

    locale_for_account(@me) do
      mail to: @me.user_email, subject: I18n.t('admin_mailer.new_report.subject', instance: @instance, id: @report.id)
    end
  end

  def new_pending_account(recipient, user)
    @account  = user.account
    @me       = recipient
    @instance = Rails.configuration.x.local_domain

    locale_for_account(@me) do
      mail to: @me.user_email, subject: I18n.t('admin_mailer.new_pending_account.subject', instance: @instance, username: @account.username)
    end
  end

  def new_trending_tags(recipient, tags)
    @tags                = tags
    @me                  = recipient
    @instance            = Rails.configuration.x.local_domain
    @lowest_trending_tag = Trends.tags.get(true, Trends.tags.options[:review_threshold]).last

    locale_for_account(@me) do
      mail to: @me.user_email, subject: I18n.t('admin_mailer.new_trending_tags.subject', instance: @instance)
    end
  end

  def new_trending_links(recipient, links)
    @links                = links
    @me                   = recipient
    @instance             = Rails.configuration.x.local_domain
    @lowest_trending_link = Trends.links.get(true, Trends.links.options[:review_threshold]).last

    locale_for_account(@me) do
      mail to: @me.user_email, subject: I18n.t('admin_mailer.new_trending_links.subject', instance: @instance)
    end
  end
end
