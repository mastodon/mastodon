require 'pathname'

# Public: A Class containing all the metadata and utilities needed to manage a
# ruby project.
class ThisProject
  # The name of this project
  attr_accessor :name

  # The author's name
  attr_accessor :author

  # The email address of the author(s)
  attr_accessor :email

  # The homepage of this project
  attr_accessor :homepage

  # The regex of files to exclude from the manifest
  attr_accessor :exclude_from_manifest

  # The hash of Gem::Specifications keyed' by platform
  attr_accessor :gemspecs

  # Public: Initialize ThisProject
  #
  # Yields self
  def initialize(&block)
    @exclude_from_manifest = Regexp.union(/\.(git|DS_Store)/,
                                          /^(doc|coverage|pkg|tmp|Gemfile(\.lock)?)/,
                                          /^[^\/]+\.gemspec/,
                                          /\.(swp|jar|bundle|so|rvmrc|travis.yml)$/,
                                          /~$/)
    @gemspecs              = Hash.new
    yield self if block_given?
  end

  # Public: return the version of ThisProject
  #
  # Search the ruby files in the project looking for the one that has the
  # version string in it. This does not eval any code in the project, it parses
  # the source code looking for the string.
  #
  # Returns a String version
  def version
    [ "lib/#{ name }.rb", "lib/#{ name }/version.rb" ].each do |v|
      path = project_path( v )
      line = path.read[/^\s*VERSION\s*=\s*.*/]
      if line then
        return line.match(/.*VERSION\s*=\s*['"](.*)['"]/)[1]
      end
    end
  end

  # Internal: Return a section of an RDoc file with the given section name
  #
  # path         - the relative path in the project of the file to parse
  # section_name - the section out of the file from which to parse data
  #
  # Retuns the text of the section as an array of paragrphs.
  def section_of( file, section_name )
    re    = /^[=#]+ (.*)$/
    sectional = project_path( file )
    parts = sectional.read.split( re )[1..-1]
    parts.map! { |p| p.strip }

    sections = Hash.new
    Hash[*parts].each do |k,v|
      sections[k] = v.split("\n\n")
    end
    return sections[section_name]
  end

  # Internal: print out a warning about the give task
  def task_warning( task )
    warn "WARNING: '#{task}' tasks are not defined. Please run 'rake develop'"
  end

  # Internal: Return the full path to the file that is relative to the project
  # root.
  #
  # path - the relative path of the file from the project root
  #
  # Returns the Pathname of the file
  def project_path( *relative_path )
    project_root.join( *relative_path )
  end

  # Internal: The absolute path of this file
  #
  # Returns the Pathname of this file.
  def this_file_path
    Pathname.new( __FILE__ ).expand_path
  end

  # Internal: The root directory of this project
  #
  # This is defined as being the directory that is in the path of this project
  # that has the first Rakefile
  #
  # Returns the Pathname of the directory
  def project_root
    this_file_path.ascend do |p|
      rakefile = p.join( 'Rakefile' )
      return p if rakefile.exist?
    end
  end

  # Internal: Returns the contents of the Manifest.txt file as an array
  #
  # Returns an Array of strings
  def manifest
    manifest_file = project_path( "Manifest.txt" )
    abort "You need a Manifest.txt" unless manifest_file.readable?
    manifest_file.readlines.map { |l| l.strip }
  end

  # Internal: Return the files that define the extensions
  #
  # Returns an Array
  def extension_conf_files
    manifest.grep( /extconf.rb\Z/ )
  end

  # Internal: Returns the gemspace associated with the current ruby platform
  def platform_gemspec
    gemspecs.fetch(platform) { This.ruby_gemspec }
  end

  def core_gemspec
    Gem::Specification.new do |spec|
      spec.name        = name
      spec.version     = version
      spec.author      = author
      spec.email       = email
      spec.homepage    = homepage

      spec.summary     = summary
      spec.description = description
      spec.license     = license

      spec.files       = manifest
      spec.executables = spec.files.grep(/^bin/) { |f| File.basename(f) }
      spec.test_files  = spec.files.grep(/^spec/)

      spec.extra_rdoc_files += spec.files.grep(/(txt|rdoc|md)$/)
      spec.rdoc_options = [ "--main"  , 'README.md',
                            "--markup", "tomdoc" ]

      spec.required_ruby_version = '>= 1.9.3'
    end
  end

  # Internal: Return the gemspec for the ruby platform
  def ruby_gemspec( core = core_gemspec, &block )
    yielding_gemspec( 'ruby', core, &block )
  end

  # Internal: Return the gemspec for the jruby platform
  def java_gemspec( core = core_gemspec, &block )
    yielding_gemspec( 'java', core, &block )
  end

  # Internal: give an initial spec and a key, create a new gemspec based off of
  # it.
  #
  # This will force the new gemspecs 'platform' to be that of the key, since the
  # only reason you would have multiple gemspecs at this point is to deal with
  # different platforms.
  def yielding_gemspec( key, core )
    spec = gemspecs[key] ||= core.dup
    spec.platform = key
    yield spec if block_given?
    return spec
  end

  # Internal: Return the platform of ThisProject at the current moment in time.
  def platform
    (RUBY_PLATFORM == "java") ? 'java' : Gem::Platform::RUBY
  end

  # Internal: Return the DESCRIPTION section of the README.rdoc file
  def description_section
    section_of( 'README.md', 'Hitimes')
  end

  # Internal: Return the summary text from the README
  def summary
    description_section.first
  end

  # Internal: Return the full description text from the README
  def description
    description_section.join(" ").tr("\n", ' ').gsub(/[{}]/,'').gsub(/\[[^\]]+\]/,'') # strip rdoc
  end

  def license
    "ISC"
  end

  # Internal: The path to the gemspec file
  def gemspec_file
    project_path( "#{ name }.gemspec" )
  end
end

This = ThisProject.new
