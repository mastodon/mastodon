# frozen_string_literal: true

class Follow < ApplicationRecord
  include Paginable
  include Streamable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  has_one :notification, as: :activity, dependent: :destroy

  validates :account, :target_account, presence: true
  validates :account_id, uniqueness: { scope: :target_account_id }

  def verb
    destroyed? ? :unfollow : :follow
  end

  def target
    target_account
  end

  def object_type
    :person
  end

  def title
    destroyed? ? "#{account.acct} is no longer following #{target_account.acct}" : "#{account.acct} started following #{target_account.acct}"
  end

  after_create  :add_to_graph
  after_destroy :remove_from_graph

  def sync!
    add_to_graph
  end

  private

  def add_to_graph
    neo = Neography::Rest.new

    a = neo.create_unique_node('account_index', 'Account', account_id.to_s, account_id: account_id)
    b = neo.create_unique_node('account_index', 'Account', target_account_id.to_s, account_id: target_account_id)

    neo.create_unique_relationship('follow_index', 'Follow', id.to_s, 'follows', a, b)
  rescue Neography::NeographyError, Excon::Error::Socket => e
    Rails.logger.error e
  end

  def remove_from_graph
    neo = Neography::Rest.new
    rel = neo.get_relationship_index('follow_index', 'Follow', id.to_s)
    neo.delete_relationship(rel)
  rescue Neography::NeographyError, Excon::Error::Socket => e
    Rails.logger.error e
  end
end
