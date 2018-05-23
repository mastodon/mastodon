# frozen_string_literal: true

module Devise
  module Controllers
    module ScopedViews
      extend ActiveSupport::Concern

      module ClassMethods
        def scoped_views?
          defined?(@scoped_views) ? @scoped_views : Devise.scoped_views
        end

        def scoped_views=(value)
          @scoped_views = value
        end
      end
    end
  end
end
