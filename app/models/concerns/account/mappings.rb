# frozen_string_literal: true

module Account::Mappings
  extend ActiveSupport::Concern

  class_methods do
    def following_map(target_account_ids, account_id)
      Follow.where(target_account_id: target_account_ids, account_id: account_id).each_with_object({}) do |follow, mapping|
        mapping[follow.target_account_id] = {
          reblogs: follow.show_reblogs?,
          notify: follow.notify?,
          languages: follow.languages,
        }
      end
    end

    def followed_by_map(target_account_ids, account_id)
      build_mapping(
        Follow.where(account_id: target_account_ids, target_account_id: account_id),
        :account_id
      )
    end

    def blocking_map(target_account_ids, account_id)
      build_mapping(
        Block.where(target_account_id: target_account_ids, account_id: account_id),
        :target_account_id
      )
    end

    def blocked_by_map(target_account_ids, account_id)
      build_mapping(
        Block.where(account_id: target_account_ids, target_account_id: account_id),
        :account_id
      )
    end

    def muting_map(target_account_ids, account_id)
      Mute.where(target_account_id: target_account_ids, account_id: account_id).each_with_object({}) do |mute, mapping|
        mapping[mute.target_account_id] = {
          notifications: mute.hide_notifications?,
          expires_at: mute.expires_at,
        }
      end
    end

    def requested_map(target_account_ids, account_id)
      FollowRequest.where(target_account_id: target_account_ids, account_id: account_id).each_with_object({}) do |follow_request, mapping|
        mapping[follow_request.target_account_id] = {
          reblogs: follow_request.show_reblogs?,
          notify: follow_request.notify?,
          languages: follow_request.languages,
        }
      end
    end

    def requested_by_map(target_account_ids, account_id)
      build_mapping(
        FollowRequest.where(account_id: target_account_ids, target_account_id: account_id),
        :account_id
      )
    end

    def endorsed_map(target_account_ids, account_id)
      build_mapping(
        AccountPin.where(account_id: account_id, target_account_id: target_account_ids),
        :target_account_id
      )
    end

    def account_note_map(target_account_ids, account_id)
      AccountNote.where(target_account_id: target_account_ids, account_id: account_id).each_with_object({}) do |note, mapping|
        mapping[note.target_account_id] = {
          comment: note.comment,
        }
      end
    end

    def domain_blocking_map_by_domain(target_domains, account_id)
      build_mapping(
        AccountDomainBlock.where(account_id: account_id, domain: target_domains),
        :domain
      )
    end

    private

    def build_mapping(query, field)
      query
        .pluck(field)
        .index_with(true)
    end
  end

  def preload_relations!(...)
    @preloaded_relations = relations_map(...)
  end

  private

  def relations_map(account_ids, domains = nil, **options)
    relations = {
      blocked_by: Account.blocked_by_map(account_ids, id),
      following: Account.following_map(account_ids, id),
    }

    return relations if options[:skip_blocking_and_muting]

    relations.merge!({
      blocking: Account.blocking_map(account_ids, id),
      muting: Account.muting_map(account_ids, id),
      domain_blocking_by_domain: Account.domain_blocking_map_by_domain(domains, id),
    })
  end
end
