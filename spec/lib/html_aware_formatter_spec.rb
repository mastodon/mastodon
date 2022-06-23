require 'rails_helper'

RSpec.describe HtmlAwareFormatter do
  describe '#to_s' do
    let(:options) { {} }
    subject { described_class.new(text, local, options).to_s }

    context 'when local' do
      let(:local) { true }
      let(:text) { 'Foo bar' }

      it 'returns formatted text' do
        is_expected.to eq '<p>Foo bar</p>'
      end
    end

    context 'when remote' do
      let(:local) { false }

      context 'given plain text' do
        let(:text) { 'Beep boop' }

        it 'keeps the plain text' do
          is_expected.to include 'Beep boop'
        end
      end

      context 'given javascript links' do
        let(:text) { '<a href="javascript:alert(42)">javascript:alert(42)</a>' }

        it 'strips the javascript links' do
          is_expected.to_not include '<a'
        end
      end

      context 'given mentions' do
        let(:account) { Fabricate(:account, domain: 'remote.com', username: 'foo', url: 'https://remote.com/@foo', uri: 'https://remote.com/users/foo', display_name: 'f. oo') }
        let(:options) { { preloaded_accounts: [account] } }

        context 'with Mastodon-style mentions' do
          let(:text) { '<a href="https://remote.com/@foo" class="mention">@<span>foo</span></a>' }

          it 'rewrites mentions' do
            is_expected.to include '>@<span>foo</span></a>'
            is_expected.to include 'href="https://remote.com/@foo"'
          end
        end

        context 'with Smithereen-style mentions' do
          let(:text) { '<a href="https://remote.com/@foo" class="u-url mention">f. oo</a>' }

          it 'rewrites mentions' do
            is_expected.to include '>@<span>foo</span></a>'
            is_expected.to include 'href="https://remote.com/@foo"'
          end
        end

        context 'with Friendica-style mentions' do
          let(:text) { '<a href="https://remote.com/users/foo" class="mention">@<span>foo</span></a>' }

          it 'rewrites mentions' do
            is_expected.to include '>@<span>foo</span></a>'
            is_expected.to include 'href="https://remote.com/@foo"'
          end
        end

        context 'with Hubzilla-style mentions' do
          let(:text) { '@<a class="zrl" href="https://remote.com/users/foo" target="_blank"  rel="nofollow noopener">f. oo</a>' }

          it 'rewrites mentions' do
            is_expected.to include '>@<span>foo</span></a>'
            is_expected.to include 'href="https://remote.com/@foo"'
          end

          it 'does not have a @ outside the link' do
            is_expected.not_to include '@<a'
          end
        end
      end

      context 'given text containing script tags' do
        let(:text) { '<script>alert("Hello")</script>' }

        it 'strips the scripts' do
          is_expected.to_not include '<script>alert("Hello")</script>'
        end
      end

      context 'given text containing malicious classes' do
        let(:text) { '<span class="mention  status__content__spoiler-link">Show more</span>' }

        it 'strips the malicious classes' do
          is_expected.to_not include 'status__content__spoiler-link'
        end
      end
    end
  end
end
