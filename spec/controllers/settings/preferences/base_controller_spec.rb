# frozen_string_literal: true

require 'rails_helper'

describe Settings::Preferences::BaseController do
  describe 'after_update_redirect_path' do
    it 'raises error when called' do
      expect { described_class.new.send(:after_update_redirect_path) }.to raise_error(/Override/)
    end
  end
end
