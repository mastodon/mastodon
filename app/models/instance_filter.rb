# frozen_string_literal: true

class InstanceFilter
  KEYS = %i(
    status
    by_domain
    availability
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Instance.includes(:domain_block, :domain_allow, :unavailable_domain).order(accounts_count: :desc)

    params.each do |key, value|
      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'status'
      status_scope(value)
    when 'by_domain'
      Instance.matches_domain(value)
    when 'availability'
      availability_scope(value)
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end

  def status_scope(value)
    # The `join where` queries here look like they have a bug due to `domain_block`
    # vs `domain_blocks`, however the table is `domain_blocks` while the relation on
    # Instances is `domain_block`
    case value.to_sym
    when :allowed
      Instance.joins(:domain_allow).reorder(Arel.sql('domain_allows.id desc'))
    when :suspended
      Instance.joins(:domain_block).where(domain_blocks: { severity: :suspend }).reorder(Arel.sql('domain_blocks.id desc'))
    when :silenced
      Instance.joins(:domain_block).where(domain_blocks: { severity: :silence }).reorder(Arel.sql('domain_blocks.id desc'))
    when :noop
      Instance.joins(:domain_block).where(domain_blocks: { severity: :noop }).reorder(Arel.sql('domain_blocks.id desc'))
    when :not_limited
      # Finds all instances where there isn't a record in the domain_blocks table
      Instance.left_outer_joins(:domain_block).where(domain_blocks: { domain: nil })
    else
      raise Mastodon::InvalidParameterError, "Unknown limited scope value: #{value}"
    end
  end

  def availability_scope(value)
    case value
    when 'failing'
      Instance.where(domain: DeliveryFailureTracker.warning_domains)
    when 'unavailable'
      Instance.joins(:unavailable_domain)
    else
      raise Mastodon::InvalidParameterError, "Unknown availability: #{value}"
    end
  end
end
