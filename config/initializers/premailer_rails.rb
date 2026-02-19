# frozen_string_literal: true

require_relative '../../lib/premailer_bundled_asset_strategy'

Premailer::Rails.config.merge!(remove_ids: true,
                               adapter: :nokogiri,
                               generate_text_part: false,
                               css_to_attributes: false,
                               strategies: [PremailerBundledAssetStrategy])
