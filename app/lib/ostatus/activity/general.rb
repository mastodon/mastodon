# frozen_string_literal: true

class OStatus::Activity::General < OStatus::Activity::Base
  def specialize
    special_class&.new(@xml, @account, @options)
  end

  private

  def special_class
    case verb
    when :post
      OStatus::Activity::Post
    when :share
      OStatus::Activity::Share
    when :delete
      OStatus::Activity::Deletion
    end
  end
end
