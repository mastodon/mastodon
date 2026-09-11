# frozen_string_literal: true

class Form::DomainBlockBatch < Form::BaseBatch
  attr_accessor :domain_blocks_attributes

  def save
    case action
    when 'save'
      save!
    end
  end

  private

  def domain_blocks
    @domain_blocks ||= domain_blocks_attributes.values.filter_map do |attributes|
      DomainBlock.new(attributes.without('enabled')) if ActiveModel::Type::Boolean.new.cast(attributes['enabled'])
    end
  end

  def save!
    domain_blocks.each do |domain_block|
      authorize(domain_block, :create?)
      next if DomainBlock.rule_for(domain_block.domain).present?

      domain_block.save!
      DomainBlockWorker.perform_async(domain_block.id)
      log_action :create, domain_block
    end
  end
end
