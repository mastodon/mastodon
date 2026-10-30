# frozen_string_literal: true

require 'yaml'
require_relative 'env_scanner'

module Mastodon
  module Configuration
    # Generates a JSON Schema (draft 2020-12) describing every environment
    # variable that Mastodon reads at start-up or run-time.
    #
    # Property metadata lives in annotations.yml next to this file.  The
    # EnvScanner is the authoritative list of which variables actually exist
    # in the codebase; annotations provide the human-readable descriptions,
    # types, groups, and constraints on top.
    #
    # To document a new environment variable:
    #   1. Add it to annotations.yml with at minimum `type`, `group`, and
    #      `description` fields.
    #   2. Run `bundle exec rails mastodon:config:schema > mastodon-config.schema.json`
    #      to regenerate the committed schema file.
    #
    # Custom JSON Schema extensions used here:
    #   x-group            – logical grouping name for UI clustering
    #   x-secret           – true when the value must never be displayed or logged
    #   x-restart-required – false when a live reload is sufficient (rare)
    #   x-status           – "deprecated" or "removed" (absent means active)
    #   x-version-history  – ordered list of {version, change} entries
    #   x-example-value    – representative value shown in docs
    #   x-anchor           – explicit anchor override (rare; "" to suppress)
    #   x-hints            – list of {style, body} Hugo hint shortcodes
    #   x-extra            – prose paragraph rendered after the hints
    #   x-trailing         – prose paragraph rendered after the example value
    #   x-show-default     – when true, emit a "**Default:** `…`" line
    #   x-suppress-removed-hint – when true, render "removed" prose plain (no danger hint)
    #   x-docs-layout      – top-level docs structure (frontmatter + section tree)
    #
    # The `docs_only_variables` key inside the layout holds annotation entries
    # for variables that should appear in the rendered Markdown but are not
    # part of the live configuration surface (tombstones for removed vars,
    # external/Rails-internal vars upstream documents).
    module Schema
      ANNOTATIONS_FILE = File.join(__dir__, 'annotations.yml')
      RESERVED_KEYS    = %w(docs docs_only_variables).freeze

      # Returns the full JSON Schema as a Ruby Hash.
      def self.generate
        annotations = YAML.load_file(ANNOTATIONS_FILE, aliases: true)
        docs_layout = annotations['docs']
        docs_only   = annotations['docs_only_variables'] || {}

        schema = {
          '$schema'     => 'https://json-schema.org/draft/2020-12/schema',
          '$id'         => 'https://joinmastodon.org/schemas/environment-config',
          'title'       => 'Mastodon environment configuration',
          'description' => 'Environment variables recognised by a Mastodon instance.',
          'type'        => 'object',
          'properties'  => build_properties(annotations),
        }

        if docs_layout
          layout = docs_layout.dup
          unless docs_only.empty?
            layout['docs_only_variables'] = docs_only.transform_values do |meta|
              annotation_to_property(meta)
            end
          end
          schema['x-docs-layout'] = layout
        end

        schema
      end

      # ---------------------------------------------------------------------------

      def self.build_properties(annotations)
        annotations.each_with_object({}) do |(key, meta), h|
          next if RESERVED_KEYS.include?(key)
          h[key] = annotation_to_property(meta)
        end
      end
      private_class_method :build_properties

      def self.annotation_to_property(meta)
        h = {
          'type'        => meta['type'],
          'description' => meta['description'],
          'x-group'     => meta['group'],
        }
        h['default']            = meta['default']          if meta.key?('default')
        h['x-secret']           = true                     if meta['secret']
        h['x-restart-required'] = false                    if meta['restart_not_required']
        h['enum']               = meta['enum']             if meta['enum']
        h['format']             = meta['format']           if meta['format']
        h['examples']           = meta['examples']         if meta['examples']
        h['minimum']            = meta['minimum']          if meta.key?('minimum')
        h['maximum']            = meta['maximum']          if meta.key?('maximum')
        h['x-status']           = meta['status']           if meta['status'] && meta['status'] != 'active'
        h['x-version-history']  = meta['version_history']  if meta['version_history']
        h['x-example-value']    = meta['example_value']    if meta.key?('example_value')
        h['x-anchor']           = meta['anchor']           if meta['anchor']
        h['x-hints']            = meta['hints']            if meta['hints']
        h['x-show-default']     = true                     if meta['show_default']
        h['x-extra']            = meta['extra']            if meta['extra']
        h['x-trailing']         = meta['trailing']         if meta['trailing']
        h['x-suppress-removed-hint'] = true                if meta['suppress_removed_hint']
        h
      end
      private_class_method :annotation_to_property
    end
  end
end
