# frozen_string_literal: true

module ViteRuby::ManifestIntegrityExtension
  def path_and_integrity_for(name, **)
    entry = lookup!(name, **)

    { path: entry.fetch('file'), integrity: entry.fetch('integrity', nil) }
  end

  # Find a manifest entry by the *final* file name
  def integrity_hash_for_file(file_name)
    @integrity_cache ||= {}
    @integrity_cache[file_name] ||= begin
      entry = manifest.find { |_key, entry| entry['file'] == file_name }

      entry[1].fetch('integrity', nil) if entry
    end
  end

  def resolve_entries_with_integrity(*names, **options)
    entries = names.map { |name| lookup!(name, **options) }
    script_paths = entries.map do |entry|
      {
        file: entry.fetch('file'),
        integrity: entry.fetch('integrity'),
      }
    end

    imports = dev_server_running? ? [] : entries.flat_map { |entry| entry['imports'] }.compact

    {
      scripts: script_paths,
      imports: imports.filter_map { |entry| { file: entry.fetch('file'), integrity: entry.fetch('integrity') } }.uniq,
      stylesheets: dev_server_running? ? [] : (entries + imports).flat_map { |entry| entry['css'] }.compact.uniq,
    }
  end
end

ViteRuby::Manifest.prepend ViteRuby::ManifestIntegrityExtension

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
            **options
          )
        end
      end
    end
  end

  def vite_stylesheet_tag(*names, **options)
    ''.html_safe.tap do |tags|
      names.each do |name|
        entry = vite_manifest.path_and_integrity_for(name, type: :stylesheet)

        options[:extname] = false if Rails::VERSION::MAJOR >= 7

        tags << stylesheet_link_tag(entry[:path], integrity: entry[:integrity], **options)
      end
    end
  end
end

ViteRails::TagHelpers.prepend ViteRails::TagHelpers::IntegrityExtension
