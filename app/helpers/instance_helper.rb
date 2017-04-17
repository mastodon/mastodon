# frozen_string_literal: true

module InstanceHelper
  def site_title
    Setting.site_title.to_s
  end
end
