# frozen_string_literal: true

module ViteRuby::ManifestIntegrityExtension
  def path_and_integrity_for(name, **)
    entry = lookup!(name, **)

    { path: entry.fetch('file'), integrity: entry.fetch('integrity', nil) }
  end

  def load_manifest
    # Invalidate the name lookup cache when reloading manifest
    @name_lookup_cache = nil unless dev_server_running?

    super
  end

  def load_name_lookup_cache
    Oj.load(config.build_output_dir.join('.vite/manifest-lookup.json').read)
  end

  # Upstream's `virtual` type is a hack, re-implement it with efficient exact name lookup
  def resolve_virtual_entry(name)
    return name if dev_server_running?

    @name_lookup_cache ||= load_name_lookup_cache

    @name_lookup_cache.fetch(name)
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
        # TODO: Secure this so we require the integrity hash outside of dev
        integrity: entry['integrity'],
      }
    end

    imports = dev_server_running? ? [] : entries.flat_map { |entry| entry['imports'] }.compact

    {
      scripts: script_paths,
      imports: imports.filter_map { |entry| { file: entry.fetch('file'), integrity: entry.fetch('integrity') } }.uniq,
      stylesheets: dev_server_running? ? [] : (entries + imports).flat_map { |entry| entry['css'] }.compact.uniq,
    }
  end

  # We need to override this method to not include the manifest, as in our case it is too large and will cause a JSON max nesting error rather than raising the expected exception
  def missing_entry_error(name, **)
    raise ViteRuby::MissingEntrypointError.new(
      file_name: resolve_entry_name(name, **),
      last_build: builder.last_build_metadata,
      manifest: '',
      config: config
    )
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
