# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormattingHelper do
  include Devise::Test::ControllerHelpers

  describe '#rss_status_content_format' do
    subject { helper.rss_status_content_format(status) }

    context 'with a simple status' do
      let(:status) { Fabricate.build :status, text: 'Hello world' }

      it 'renders the formatted elements' do
        expect(subject)
          .to eq('<p>Hello world</p>')
      end
    end

    context 'with a spoiler and an emoji and a poll' do
      let(:status) { Fabricate(:status, text: 'Hello :world: <>', spoiler_text: 'This is a spoiler<>', poll: Fabricate(:poll, options: %w(Yes<> No))) }

      before { Fabricate :custom_emoji, shortcode: 'world' }

      it 'renders the formatted elements' do
        expect(subject)
          .to include('<p><strong>Content warning:</strong>This is a spoiler&lt;&gt;</p><hr>')
          .and include('<p>Hello <img rel="emoji" draggable="false"')
          .and include('emojo.png"> &lt;&gt;</p>')
          .and include('<radio disabled="disabled">Yes&lt;&gt;</radio><br>')
      end
    end
  end
end
