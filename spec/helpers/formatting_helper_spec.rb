# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormattingHelper do
  include Devise::Test::ControllerHelpers

  describe '#rss_status_content_format' do
    subject { helper.rss_status_content_format(status) }

    let(:status) { Fabricate(:status, text: 'Hello world<>', spoiler_text: 'This is a spoiler<>', poll: Fabricate(:poll, options: %w(Yes<> No))) }

    it 'renders the formatted elements' do
      expect(subject)
        .to include('<p>This is a spoiler&lt;&gt;</p><hr>')
        .and include('<p>Hello world&lt;&gt;</p>')
        .and include('<radio disabled="disabled">Yes&lt;&gt;</radio><br>')
    end
  end
end
