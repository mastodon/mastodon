Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'tilt'
  s.version = '2.0.8'
  s.date = '2017-07-24'

  s.description = "Generic interface to multiple Ruby template engines"
  s.summary     = s.description
  s.license     = "MIT"

  s.authors = ["Ryan Tomayko"]
  s.email = "r@tomayko.com"

  # = MANIFEST =
  s.files = %w[
    CHANGELOG.md
    COPYING
    Gemfile
    HACKING
    README.md
    Rakefile
    bin/tilt
    docs/TEMPLATES.md
    docs/common.css
    lib/tilt.rb
    lib/tilt/asciidoc.rb
    lib/tilt/babel.rb
    lib/tilt/bluecloth.rb
    lib/tilt/builder.rb
    lib/tilt/coffee.rb
    lib/tilt/commonmarker.rb
    lib/tilt/creole.rb
    lib/tilt/csv.rb
    lib/tilt/dummy.rb
    lib/tilt/erb.rb
    lib/tilt/erubi.rb
    lib/tilt/erubis.rb
    lib/tilt/etanni.rb
    lib/tilt/haml.rb
    lib/tilt/kramdown.rb
    lib/tilt/less.rb
    lib/tilt/liquid.rb
    lib/tilt/livescript.rb
    lib/tilt/mapping.rb
    lib/tilt/markaby.rb
    lib/tilt/maruku.rb
    lib/tilt/nokogiri.rb
    lib/tilt/pandoc.rb
    lib/tilt/plain.rb
    lib/tilt/prawn.rb
    lib/tilt/radius.rb
    lib/tilt/rdiscount.rb
    lib/tilt/rdoc.rb
    lib/tilt/redcarpet.rb
    lib/tilt/redcloth.rb
    lib/tilt/rst-pandoc.rb
    lib/tilt/sass.rb
    lib/tilt/sigil.rb
    lib/tilt/string.rb
    lib/tilt/template.rb
    lib/tilt/typescript.rb
    lib/tilt/wikicloth.rb
    lib/tilt/yajl.rb
    man/index.txt
    man/tilt.1.ronn
    test/markaby/locals.mab
    test/markaby/markaby.mab
    test/markaby/markaby_other_static.mab
    test/markaby/render_twice.mab
    test/markaby/scope.mab
    test/markaby/yielding.mab
    test/mytemplate.rb
    test/test_helper.rb
    test/tilt_asciidoctor_test.rb
    test/tilt_babeltemplate.rb
    test/tilt_blueclothtemplate_test.rb
    test/tilt_buildertemplate_test.rb
    test/tilt_cache_test.rb
    test/tilt_coffeescripttemplate_test.rb
    test/tilt_commonmarkertemplate_test.rb
    test/tilt_compilesite_test.rb
    test/tilt_creoletemplate_test.rb
    test/tilt_csv_test.rb
    test/tilt_erbtemplate_test.rb
    test/tilt_erubistemplate_test.rb
    test/tilt_erubitemplate_test.rb
    test/tilt_etannitemplate_test.rb
    test/tilt_hamltemplate_test.rb
    test/tilt_kramdown_test.rb
    test/tilt_lesstemplate_test.less
    test/tilt_lesstemplate_test.rb
    test/tilt_liquidtemplate_test.rb
    test/tilt_livescripttemplate_test.rb
    test/tilt_mapping_test.rb
    test/tilt_markaby_test.rb
    test/tilt_markdown_test.rb
    test/tilt_marukutemplate_test.rb
    test/tilt_metadata_test.rb
    test/tilt_nokogiritemplate_test.rb
    test/tilt_pandoctemplate_test.rb
    test/tilt_prawntemplate.prawn
    test/tilt_prawntemplate_test.rb
    test/tilt_radiustemplate_test.rb
    test/tilt_rdiscounttemplate_test.rb
    test/tilt_rdoctemplate_test.rb
    test/tilt_redcarpettemplate_test.rb
    test/tilt_redclothtemplate_test.rb
    test/tilt_rstpandoctemplate_test.rb
    test/tilt_sasstemplate_test.rb
    test/tilt_sigil_test.rb
    test/tilt_stringtemplate_test.rb
    test/tilt_template_test.rb
    test/tilt_test.rb
    test/tilt_typescript_test.rb
    test/tilt_wikiclothtemplate_test.rb
    test/tilt_yajltemplate_test.rb
    tilt.gemspec
  ]
  # = MANIFEST =

  s.executables = ['tilt']
  s.test_files = s.files.select {|path| path =~ /^test\/.*_test.rb/}

  s.homepage = "http://github.com/rtomayko/tilt/"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Tilt", "--main", "Tilt"]
  s.require_paths = %w[lib]
  s.rubygems_version = '1.1.1'
end
