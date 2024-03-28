# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BaseService do
  describe '#call' do
    it 'raises for subclass implementation' do
      expect { described_class.new.call }
        .to raise_error(NotImplementedError)
    end
  end

  it 'includes needed modules' do
    expect(described_class)
      .to include(ActionView::Helpers::SanitizeHelper)
      .and include(ActionView::Helpers::TextHelper)
      .and include(RoutingHelper)
  end
end
