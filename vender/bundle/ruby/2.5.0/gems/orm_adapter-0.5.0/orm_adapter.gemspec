$:.push File.expand_path("../lib", __FILE__)
require "orm_adapter/version"

Gem::Specification.new do |s|
  s.name = "orm_adapter"
  s.version = OrmAdapter::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.authors = ["Ian White", "Jose Valim"]
  s.description = "Provides a single point of entry for using basic features of ruby ORMs"
  s.summary = "orm_adapter provides a single point of entry for using basic features of popular ruby ORMs.  Its target audience is gem authors who want to support many ruby ORMs."
  s.email = "ian.w.white@gmail.com"
  s.homepage = "http://github.com/ianwhite/orm_adapter"
  s.license = "MIT"

  s.rubyforge_project = "orm_adapter"
  s.required_rubygems_version = ">= 1.3.6"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "git", ">= 1.2.5"
  s.add_development_dependency "yard", ">= 0.6.0"
  s.add_development_dependency "rake", ">= 0.8.7"
  s.add_development_dependency "activerecord", ">= 3.2.15"
  s.add_development_dependency "mongoid", "~> 2.8.0"
  s.add_development_dependency "mongo_mapper", "~> 0.11.0"
  s.add_development_dependency "bson_ext", ">= 1.3.0"
  s.add_development_dependency "rspec", ">= 2.4.0"
  s.add_development_dependency "sqlite3", ">= 1.3.2"
  s.add_development_dependency "datamapper", ">= 1.0"
  s.add_development_dependency "dm-sqlite-adapter", ">= 1.0"
  s.add_development_dependency "dm-active_model", ">= 1.0"
end

