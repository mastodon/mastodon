require 'json/ld'

module JSON::LD::Context::Preloaded
  autoload :VERSION, "json/ld/preloaded/version"
end

# Require individual context files here
load "json/ld/preloaded/activitystreams.rb"
load "json/ld/preloaded/csvw.rb"
load "json/ld/preloaded/datacube.rb"
load "json/ld/preloaded/entityfacts.rb"
load "json/ld/preloaded/foaf.rb"
load "json/ld/preloaded/geojson.rb"
load "json/ld/preloaded/hydra.rb"
load "json/ld/preloaded/identity.rb"
load "json/ld/preloaded/iiif.rb"
load "json/ld/preloaded/lov.rb"
load "json/ld/preloaded/oa.rb"
load "json/ld/preloaded/prefix.rb"
load "json/ld/preloaded/presentation.rb"
load "json/ld/preloaded/rdfa.rb"
load "json/ld/preloaded/research.rb"
load "json/ld/preloaded/schema.rb"
load "json/ld/preloaded/vcard.rb"
