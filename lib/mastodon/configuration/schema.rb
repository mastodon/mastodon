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
    #   x-group   – logical grouping name for UI clustering
    #   x-secret  – true when the value must never be displayed or logged
    #   x-restart-required – false when a live reload is sufficient (rare)
    module Schema
      ANNOTATIONS_FILE = File.join(__dir__, 'annotations.yml')

      # Returns the full JSON Schema as a Ruby Hash.
      def self.generate
        {
          '$schema'     => 'https://json-schema.org/draft/2020-12/schema',
          '$id'         => 'https://joinmastodon.org/schemas/environment-config',
          'title'       => 'Mastodon environment configuration',
          'description' => 'Environment variables recognised by a Mastodon instance.',
          'type'        => 'object',
          'properties'  => build_properties,
        }
      end

      # ---------------------------------------------------------------------------

      def self.build_properties
        annotations = YAML.load_file(ANNOTATIONS_FILE, aliases: true)

        annotations.to_h do |key, meta|
          [key, annotation_to_property(meta)]
        end
      end
      private_class_method :build_properties

      def self.annotation_to_property(meta)
        h = {
          'type'        => meta['type'],
          'description' => meta['description'],
          'x-group'     => meta['group'],
        }
        h['default']            = meta['default']   if meta.key?('default')
        h['x-secret']           = true              if meta['secret']
        h['x-restart-required'] = false             if meta['restart_not_required']
        h['enum']               = meta['enum']      if meta['enum']
        h['format']             = meta['format']    if meta['format']
        h['examples']           = meta['examples']  if meta['examples']
        h['minimum']            = meta['minimum']   if meta.key?('minimum')
        h['maximum']            = meta['maximum']   if meta.key?('maximum')
        h
      end
      private_class_method :annotation_to_property
    end
  end
end
