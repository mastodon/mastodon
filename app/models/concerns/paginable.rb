module Paginable
  extend ActiveSupport::Concern

  included do
    scope :paginate_by_max_id, -> (limit, max_id) { order('id desc').limit(limit).where(max_id.nil? ? '1=1' : ['id < ?', max_id]) }
  end
end
