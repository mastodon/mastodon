# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe 'body_classes' do
    context 'with a body class string from a controller' do
      before do
        user = Fabricate :user
        user.settings['web.use_system_font'] = true
        user.settings['web.reduce_motion'] = true
        user.save

        helper.extend controller_helpers
      end

      it 'uses the current theme and user settings classes in the result' do
        expect(helper.body_classes)
          .to match(/theme-default/)
          .and match(/system-font/)
          .and match(/reduce-motion/)
      end

      it 'includes values set via content_for' do
        helper.content_for(:body_classes) { 'admin' }

        expect(helper.body_classes)
          .to match(/admin/)
      end

      private

      def controller_helpers
        Module.new do
          def current_account
            @current_account ||= Fabricate(:account, user: User.last)
          end

          def current_theme = 'default'
        end
      end
    end
  end

  describe 'locale_direction' do
    it 'adds rtl body class if locale is Arabic' do
      I18n.with_locale(:ar) do
        expect(helper.locale_direction).to eq 'rtl'
      end
    end

    it 'adds rtl body class if locale is Farsi' do
      I18n.with_locale(:fa) do
        expect(helper.locale_direction).to eq 'rtl'
      end
    end

    it 'adds rtl if locale is Hebrew' do
      I18n.with_locale(:he) do
        expect(helper.locale_direction).to eq 'rtl'
      end
    end

    it 'does not add rtl if locale is Thai' do
      I18n.with_locale(:th) do
        expect(helper.locale_direction).to_not eq 'rtl'
      end
    end
  end

  describe '#material_symbol' do
    it 'returns an svg with the icon and options' do
      expect(helper.material_symbol('lock', class: :test, data: { hidden: true }))
        .to match('<svg.*/svg>')
        .and match('class="icon material-lock test"')
        .and match('data-hidden="true"')
    end
  end

  describe 'open_registrations?' do
    it 'returns true when open for registrations' do
      allow(Setting).to receive(:[]).with('registrations_mode').and_return('open')

      expect(helper.open_registrations?).to be true
      expect(Setting).to have_received(:[]).with('registrations_mode')
    end

    it 'returns false when closed for registrations' do
      allow(Setting).to receive(:[]).with('registrations_mode').and_return('none')

      expect(helper.open_registrations?).to be false
      expect(Setting).to have_received(:[]).with('registrations_mode')
    end
  end

  describe 'available_sign_up_path' do
    context 'when registrations are closed' do
      before do
        allow(Setting).to receive(:[]).with('registrations_mode').and_return 'none'
      end

      it 'redirects to joinmastodon site' do
        expect(helper.available_sign_up_path).to match(/joinmastodon.org/)
      end
    end

    context 'when in omniauth only mode' do
      around do |example|
        ClimateControl.modify OMNIAUTH_ONLY: 'true' do
          example.run
        end
      end

      it 'redirects to joinmastodon site' do
        expect(helper.available_sign_up_path).to match(/joinmastodon.org/)
      end
    end

    context 'when registrations are allowed' do
      it 'returns a link to the registration page' do
        expect(helper.available_sign_up_path).to eq(new_user_registration_path)
      end
    end
  end

  describe 'omniauth_only?' do
    context 'when env var is set to true' do
      around do |example|
        ClimateControl.modify OMNIAUTH_ONLY: 'true' do
          example.run
        end
      end

      it 'returns true' do
        expect(helper).to be_omniauth_only
      end
    end

    context 'when env var is not set' do
      around do |example|
        ClimateControl.modify OMNIAUTH_ONLY: nil do
          example.run
        end
      end

      it 'returns false' do
        expect(helper).to_not be_omniauth_only
      end
    end
  end

  describe 'quote_wrap' do
    it 'indents and quote wraps text' do
      text = <<~TEXT
        Hello this is a nice message for you to quote.
        Be careful because it has two lines.
      TEXT

      expect(helper.quote_wrap(text)).to eq <<~EXPECTED.strip
        > Hello this is a nice message for you to quote.
        > Be careful because it has two lines.
      EXPECTED
    end
  end

  describe 'storage_host' do
    context 'when S3 alias is present' do
      around do |example|
        ClimateControl.modify S3_ALIAS_HOST: 's3.alias' do
          example.run
        end
      end

      it 'returns true' do
        expect(helper.storage_host).to eq('https://s3.alias')
      end
    end

    context 'when S3 alias includes a path component' do
      around do |example|
        ClimateControl.modify S3_ALIAS_HOST: 's3.alias/path' do
          example.run
        end
      end

      it 'returns a correct URL' do
        expect(helper.storage_host).to eq('https://s3.alias/path')
      end
    end

    context 'when S3 cloudfront is present' do
      around do |example|
        ClimateControl.modify S3_CLOUDFRONT_HOST: 's3.cloudfront' do
          example.run
        end
      end

      it 'returns true' do
        expect(helper.storage_host).to eq('https://s3.cloudfront')
      end
    end
  end

  describe 'storage_host?' do
    context 'when S3 alias is present' do
      around do |example|
        ClimateControl.modify S3_ALIAS_HOST: 's3.alias' do
          example.run
        end
      end

      it 'returns true' do
        expect(helper.storage_host?).to be true
      end
    end

    context 'when S3 cloudfront is present' do
      around do |example|
        ClimateControl.modify S3_CLOUDFRONT_HOST: 's3.cloudfront' do
          example.run
        end
      end

      it 'returns true' do
        expect(helper.storage_host?).to be true
      end
    end

    context 'when neither env value is present' do
      it 'returns false' do
        expect(helper.storage_host?).to be false
      end
    end
  end

  describe 'title' do
    it 'returns site title on production environment' do
      Setting.site_title = 'site title'
      allow(Rails.env).to receive(:production?).and_return(true)
      expect(helper.title).to eq 'site title'
      expect(Rails.env).to have_received(:production?)
    end

    it 'returns site title with note on non-production environment' do
      Setting.site_title = 'site title'
      allow(Rails.env).to receive(:production?).and_return(false)
      expect(helper.title).to eq 'site title (Dev)'
      expect(Rails.env).to have_received(:production?)
    end
  end

  describe 'html_title' do
    before do
      allow(Rails.env).to receive(:production?).and_return(true)
    end

    context 'with a page_title content_for value' do
      it 'uses the value in the html title' do
        Setting.site_title = 'Site Title'
        helper.content_for(:page_title, 'Test Value')

        expect(helper.html_title).to eq 'Test Value - Site Title'
        expect(helper.html_title).to be_html_safe
      end

      it 'does not escape twice' do
        Setting.site_title = 'Site Title'
        helper.content_for(:page_title, '&quot;Test Value&quot;'.html_safe)

        expect(helper.html_title).to eq '&quot;Test Value&quot; - Site Title'
        expect(helper.html_title).to be_html_safe
      end
    end

    context 'without any page_title content_for value' do
      it 'returns the site title' do
        Setting.site_title = 'Site Title'

        expect(helper.html_title).to eq 'Site Title'
        expect(helper.html_title).to be_html_safe
      end
    end
  end
end
