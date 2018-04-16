# -*- encoding: utf-8 -*-
# frozen_string_literal: true
# This file generated automatically from http://geojson.org/geojson-ld/geojson-context.jsonld
require 'json/ld'
class JSON::LD::Context
  add_preloaded("http://geojson.org/geojson-ld/geojson-context.jsonld") do
    new(processingMode: "json-ld-1.0", term_definitions: {
      "Feature" => TermDefinition.new("Feature", id: "https://purl.org/geojson/vocab#Feature", simple: true),
      "FeatureCollection" => TermDefinition.new("FeatureCollection", id: "https://purl.org/geojson/vocab#FeatureCollection", simple: true),
      "GeometryCollection" => TermDefinition.new("GeometryCollection", id: "https://purl.org/geojson/vocab#GeometryCollection", simple: true),
      "LineString" => TermDefinition.new("LineString", id: "https://purl.org/geojson/vocab#LineString", simple: true),
      "MultiLineString" => TermDefinition.new("MultiLineString", id: "https://purl.org/geojson/vocab#MultiLineString", simple: true),
      "MultiPoint" => TermDefinition.new("MultiPoint", id: "https://purl.org/geojson/vocab#MultiPoint", simple: true),
      "MultiPolygon" => TermDefinition.new("MultiPolygon", id: "https://purl.org/geojson/vocab#MultiPolygon", simple: true),
      "Point" => TermDefinition.new("Point", id: "https://purl.org/geojson/vocab#Point", simple: true),
      "Polygon" => TermDefinition.new("Polygon", id: "https://purl.org/geojson/vocab#Polygon", simple: true),
      "bbox" => TermDefinition.new("bbox", id: "https://purl.org/geojson/vocab#bbox", container_mapping: "@list"),
      "coordinates" => TermDefinition.new("coordinates", id: "https://purl.org/geojson/vocab#coordinates", container_mapping: "@list"),
      "features" => TermDefinition.new("features", id: "https://purl.org/geojson/vocab#features", container_mapping: "@set"),
      "geojson" => TermDefinition.new("geojson", id: "https://purl.org/geojson/vocab#", simple: true, prefix: true),
      "geometry" => TermDefinition.new("geometry", id: "https://purl.org/geojson/vocab#geometry", simple: true),
      "id" => TermDefinition.new("id", id: "@id", simple: true),
      "properties" => TermDefinition.new("properties", id: "https://purl.org/geojson/vocab#properties", simple: true),
      "type" => TermDefinition.new("type", id: "@type", simple: true)
    })
  end
end
