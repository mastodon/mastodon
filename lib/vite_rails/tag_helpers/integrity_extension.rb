# frozen_string_literal: true

module ViteRails::TagHelpers::IntegrityExtension
  def vite_javascript_tag(*names,
                          type: 'module',
                          asset_type: :javascript,
                          skip_preload_tags: false,
                          skip_style_tags: false,
                          crossorigin: 'anonymous',
                          media: 'screen',
                          **options)
    entries = vite_manifest.resolve_entries_with_integrity(*names, type: asset_type)

    ''.html_safe.tap do |tags|
      entries.fetch(:scripts).each do |script|
        tags << javascript_include_tag(
          script[:file],
          integrity: script[:integrity],
          crossorigin: crossorigin,
          type: type,
          extname: false,
          **options
        )
      end

      unless skip_preload_tags
        entries.fetch(:imports).each do |import|
          tags << vite_preload_tag(import[:file], integrity: import[:integrity], crossorigin: crossorigin, **options)
        end
      end

      options[:extname] = false if Rails::VERSION::MAJOR >= 7

      unless skip_style_tags
        entries.fetch(:stylesheets).each do |stylesheet|
          # This is for stylesheets imported from Javascript. The entry for the JS entrypoint only contains the final CSS file name, so we need to look it up in the manifest
          tags << stylesheet_link_tag(
            stylesheet,
            integrity: vite_manifest.integrity_hash_for_file(stylesheet),
            media: media,
            crossorigin: crossorigin,
            **options
          )
        end
      end
    end
  end

  def vite_stylesheet_tag(*names, type: :stylesheet, **options)
    ''.html_safe.tap do |tags|
      names.each do |name|
        entry = vite_manifest.path_and_integrity_for(name, type:)

        options[:extname] = false if Rails::VERSION::MAJOR >= 7

        tags << stylesheet_link_tag(entry[:path], integrity: entry[:integrity], **options)
      end
    end
  end

  def vite_preload_file_tag(name,
                            asset_type: :javascript,
                            crossorigin: 'anonymous', **options)
    ''.html_safe.tap do |tags|
      entries = vite_manifest.resolve_entries_with_integrity(name, type: asset_type)

      entries.fetch(:scripts).each do |script|
        tags << vite_preload_tag(script[:file], integrity: script[:integrity], crossorigin: crossorigin, **options)
      end
    end
  rescue ViteRuby::MissingEntrypointError
    # Ignore this error, it is not critical if the file is not preloaded
  end

  def vite_polyfills_tag(crossorigin: 'anonymous', **)
    return if ViteRuby.instance.dev_server_running?

    entry = vite_manifest.path_and_integrity_for('polyfills', type: :virtual)

    javascript_include_tag(entry[:path], type: 'module', integrity: entry[:integrity], crossorigin: crossorigin, **)
  end
end

ViteRails::TagHelpers.prepend ViteRails::TagHelpers::IntegrityExtension
