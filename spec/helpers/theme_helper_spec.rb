# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ThemeHelper do
  describe 'theme_style_tags' do
    let(:result) { helper.theme_style_tags(theme) }

    context 'when using "default" theme' do
      let(:theme) { 'default' }

      it 'returns the default stylesheet' do
        expect(html_links.last.attributes.symbolize_keys)
          .to include(
            href: have_attributes(value: match(/default/))
          )
      end
    end
  end

  describe 'theme_color_tags' do
    let(:result) { helper.theme_color_tags(color_scheme) }

    context 'when using system theme' do
      let(:color_scheme) { 'auto' }

      it 'returns both color schemes with appropriate media queries' do
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

    context 'when light color scheme' do
      let(:color_scheme) { 'light' }

      it 'returns the light color' do
        expect(html_theme_colors.first.attributes.symbolize_keys)
          .to include(
            content: have_attributes(value: Themes::THEME_COLORS[:light])
          )
      end
    end

    context 'when using dark color scheme' do
      let(:color_scheme) { 'dark' }

      it 'returns the dark color' do
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

  describe '#current_theme' do
    subject { helper.current_theme }

    context 'when user is not signed in' do
      context 'when theme was not changed in settings' do
        it { is_expected.to eq('default') }
      end

      context 'when theme is changed in settings' do
        before { Setting.theme = 'contrast' }

        it { is_expected.to eq('contrast') }
      end
    end

    context 'when user is signed in' do
      before { allow(helper).to receive(:current_user).and_return(current_user) }

      let(:current_user) { Fabricate :user }

      context 'when user did not set theme' do
        it { is_expected.to eq('default') }
      end

      context 'when user set theme' do
        before { current_user.settings.update(theme: 'alternate', noindex: false) }

        context 'when theme is valid' do
          before { allow(Themes.instance).to receive(:names).and_return %w(default alternate good evil) }

          it { is_expected.to eq('alternate') }
        end

        context 'when theme is not valid' do
          it { is_expected.to eq('default') }
        end
      end
    end
  end

  describe '#page_color_scheme' do
    subject { helper.page_color_scheme }

    context 'when force_color_scheme is present' do
      before { helper.content_for(:force_color_scheme) { 'value' } }

      it { is_expected.to eq('value') }
    end

    context 'when force_color_scheme is absent' do
      it { is_expected.to eq('auto') }
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
