# frozen_string_literal: true

class Ostatus::Activity::General < Ostatus::Activity::Base
  def specialize
    special_class&.new(@xml, @account)
  end

  private

  def special_class
    case verb
    when :post
      Ostatus::Activity::Post
    when :share
      Ostatus::Activity::Share
    when :delete
      Ostatus::Activity::Deletion
    end
  end
end
