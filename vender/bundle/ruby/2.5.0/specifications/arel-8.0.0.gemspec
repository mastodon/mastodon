# -*- encoding: utf-8 -*-
# stub: arel 8.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "arel".freeze
  s.version = "8.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Aaron Patterson".freeze, "Bryan Helmkamp".freeze, "Emilio Tagua".freeze, "Nick Kallen".freeze]
  s.date = "2017-02-21"
  s.description = "Arel Really Exasperates Logicians\n\nArel is a SQL AST manager for Ruby. It\n\n1. Simplifies the generation of complex SQL queries\n2. Adapts to various RDBMSes\n\nIt is intended to be a framework framework; that is, you can build your own ORM\nwith it, focusing on innovative object and collection modeling as opposed to\ndatabase compatibility and query generation.".freeze
  s.email = ["aaron@tenderlovemaking.com".freeze, "bryan@brynary.com".freeze, "miloops@gmail.com".freeze]
  s.extra_rdoc_files = ["History.txt".freeze, "MIT-LICENSE.txt".freeze, "README.md".freeze]
  s.files = ["History.txt".freeze, "MIT-LICENSE.txt".freeze, "README.md".freeze]
  s.homepage = "https://github.com/rails/arel".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Arel Really Exasperates Logicians  Arel is a SQL AST manager for Ruby".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.4"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<minitest>.freeze, ["~> 5.4"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<minitest>.freeze, ["~> 5.4"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
