# frozen_string_literal: true

require 'rails_helper'

describe FormattingHelper, type: :helper do
  include Devise::Test::ControllerHelpers

  describe '#rss_status_content_format' do
    let(:status) { Fabricate(:status, text: 'Hello world<>', spoiler_text: 'This is a spoiler<>', poll: Fabricate(:poll, options: %w(Yes<> No))) }
    let(:html) { helper.rss_status_content_format(status) }

    it 'renders the spoiler text' do
      expect(html).to include('<p>This is a spoiler&lt;&gt;</p><hr>')
    end

    it 'renders the status text' do
      expect(html).to include('<p>Hello world&lt;&gt;</p>')
    end

    it 'renders the poll' do
      expect(html).to include('<radio disabled="disabled">Yes&lt;&gt;</radio><br>')
    end
  end
end
