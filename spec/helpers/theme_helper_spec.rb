# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ThemeHelper do
  describe 'theme_style_tags' do
    let(:result) { helper.theme_style_tags(theme) }

    context 'when using "system" theme' do
      let(:theme) { 'system' }

      it 'returns the mastodon-light and application stylesheets with correct color schemes' do
        expect(html_links.first.attributes.symbolize_keys)
          .to include(
            href: have_attributes(value: match(/mastodon-light/)),
            media: have_attributes(value: 'not all and (prefers-color-scheme: dark)')
          )
        expect(html_links.last.attributes.symbolize_keys)
          .to include(
            href: have_attributes(value: match(/default/)),
            media: have_attributes(value: '(prefers-color-scheme: dark)')
          )
      end
    end

    context 'when using "default" theme' do
      let(:theme) { 'default' }

      it 'returns the default stylesheet' do
        expect(html_links.last.attributes.symbolize_keys)
          .to include(
            href: have_attributes(value: match(/default/))
          )
      end
    end

    context 'when using other theme' do
      let(:theme) { 'contrast' }

      it 'returns the theme stylesheet without color scheme information' do
        expect(html_links.first.attributes.symbolize_keys)
          .to include(
            href: have_attributes(value: match(/contrast/)),
            media: have_attributes(value: 'all')
          )
      end
    end
  end

  describe 'theme_color_tags' do
    let(:result) { helper.theme_color_tags(theme) }

    context 'when using system theme' do
      let(:theme) { 'system' }

      it 'returns the mastodon-light and default stylesheets with correct color schemes' do
        expect(html_theme_colors.first.attributes.symbolize_keys)
          .to include(
            content: have_attributes(value: Themes::THEME_COLORS[:dark]),
            media: have_attributes(value: '(prefers-color-scheme: dark)')
          )
        expect(html_theme_colors.last.attributes.symbolize_keys)
          .to include(
            content: have_attributes(value: Themes::THEME_COLORS[:light]),
            media: have_attributes(value: '(prefers-color-scheme: light)')
          )
      end
    end

    context 'when using mastodon-light theme' do
      let(:theme) { 'mastodon-light' }

      it 'returns the theme stylesheet without color scheme information' do
        expect(html_theme_colors.first.attributes.symbolize_keys)
          .to include(
            content: have_attributes(value: Themes::THEME_COLORS[:light])
          )
      end
    end

    context 'when using other theme' do
      let(:theme) { 'contrast' }

      it 'returns the theme stylesheet without color scheme information' do
        expect(html_theme_colors.first.attributes.symbolize_keys)
          .to include(
            content: have_attributes(value: Themes::THEME_COLORS[:dark])
          )
      end
    end
  end

  describe '#custom_stylesheet' do
    let(:custom_css) { 'body {}' }
    let(:custom_digest) { Digest::SHA256.hexdigest(custom_css) }

    before do
      Setting.custom_css = custom_css
    end

    context 'when custom css setting value digest is present' do
      before { Rails.cache.write(:setting_digest_custom_css, custom_digest) }

      it 'returns value from settings' do
        expect(custom_stylesheet)
          .to match("/css/custom-#{custom_digest[...8]}.css")
      end
    end

    context 'when custom css setting value digest is expired' do
      before { Rails.cache.delete(:setting_digest_custom_css) }

      it 'returns value from settings' do
        expect(custom_stylesheet)
          .to match("/css/custom-#{custom_digest[...8]}.css")
      end
    end

    context 'when custom css setting is not present' do
      before do
        Setting.custom_css = nil
        Rails.cache.delete(:setting_digest_custom_css)
      end

      it 'returns default value' do
        expect(custom_stylesheet)
          .to be_blank
      end
    end
  end

  private

  def html_links
    Nokogiri::HTML5.fragment(result).css('link')
  end

  def html_theme_colors
    Nokogiri::HTML5.fragment(result).css('meta[name=theme-color]')
  end
end
