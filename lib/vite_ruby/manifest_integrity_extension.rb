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
    JSON.load_file(config.build_output_dir.join('.vite/manifest-lookup.json'))
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
