# frozen_string_literal: true

module SiteTitleHelper
  def site_title
    Setting.site_title.to_s
  end
end
