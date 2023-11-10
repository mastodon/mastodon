# frozen_string_literal: true

require 'rails_helper'

describe Settings::Preferences::BaseController do
  describe 'after_update_redirect_path' do
    it 'raises error when called' do
      expect { redirect_path_callback }
        .to raise_error(/Override/)
    end

    private

    def redirect_path_callback
      described_class.new.send(:after_update_redirect_path)
    end
  end
end
