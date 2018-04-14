# frozen_string_literal: true
# Define a package task library to aid in the definition of
# redistributable package files.

require "rake"
require "rake/tasklib"

module Rake

  # Create a packaging task that will package the project into
  # distributable files (e.g zip archive or tar files).
  #
  # The PackageTask will create the following targets:
  #
  # +:package+ ::
  #   Create all the requested package files.
  #
  # +:clobber_package+ ::
  #   Delete all the package files.  This target is automatically
  #   added to the main clobber target.
  #
  # +:repackage+ ::
  #   Rebuild the package files from scratch, even if they are not out
  #   of date.
  #
  # <tt>"<em>package_dir</em>/<em>name</em>-<em>version</em>.tgz"</tt> ::
  #   Create a gzipped tar package (if <em>need_tar</em> is true).
  #
  # <tt>"<em>package_dir</em>/<em>name</em>-<em>version</em>.tar.gz"</tt> ::
  #   Create a gzipped tar package (if <em>need_tar_gz</em> is true).
  #
  # <tt>"<em>package_dir</em>/<em>name</em>-<em>version</em>.tar.bz2"</tt> ::
  #   Create a bzip2'd tar package (if <em>need_tar_bz2</em> is true).
  #
  # <tt>"<em>package_dir</em>/<em>name</em>-<em>version</em>.zip"</tt> ::
  #   Create a zip package archive (if <em>need_zip</em> is true).
  #
  # Example:
  #
  #   Rake::PackageTask.new("rake", "1.2.3") do |p|
  #     p.need_tar = true
  #     p.package_files.include("lib/**/*.rb")
  #   end
  #
  class PackageTask < TaskLib
    # Name of the package (from the GEM Spec).
    attr_accessor :name

    # Version of the package (e.g. '1.3.2').
    attr_accessor :version

    # Directory used to store the package files (default is 'pkg').
    attr_accessor :package_dir

    # True if a gzipped tar file (tgz) should be produced (default is
    # false).
    attr_accessor :need_tar

    # True if a gzipped tar file (tar.gz) should be produced (default
    # is false).
    attr_accessor :need_tar_gz

    # True if a bzip2'd tar file (tar.bz2) should be produced (default
    # is false).
    attr_accessor :need_tar_bz2

    # True if a xz'd tar file (tar.xz) should be produced (default is false)
    attr_accessor :need_tar_xz

    # True if a zip file should be produced (default is false)
    attr_accessor :need_zip

    # List of files to be included in the package.
    attr_accessor :package_files

    # Tar command for gzipped or bzip2ed archives.  The default is 'tar'.
    attr_accessor :tar_command

    # Zip command for zipped archives.  The default is 'zip'.
    attr_accessor :zip_command

    # Create a Package Task with the given name and version.  Use +:noversion+
    # as the version to build a package without a version or to provide a
    # fully-versioned package name.

    def initialize(name=nil, version=nil)
      init(name, version)
      yield self if block_given?
      define unless name.nil?
    end

    # Initialization that bypasses the "yield self" and "define" step.
    def init(name, version)
      @name = name
      @version = version
      @package_files = Rake::FileList.new
      @package_dir = "pkg"
      @need_tar = false
      @need_tar_gz = false
      @need_tar_bz2 = false
      @need_tar_xz = false
      @need_zip = false
      @tar_command = "tar"
      @zip_command = "zip"
    end

    # Create the tasks defined by this task library.
    def define
      fail "Version required (or :noversion)" if @version.nil?
      @version = nil if :noversion == @version

      desc "Build all the packages"
      task :package

      desc "Force a rebuild of the package files"
      task repackage: [:clobber_package, :package]

      desc "Remove package products"
      task :clobber_package do
        rm_r package_dir rescue nil
      end

      task clobber: [:clobber_package]

      [
        [need_tar, tgz_file, "z"],
        [need_tar_gz, tar_gz_file, "z"],
        [need_tar_bz2, tar_bz2_file, "j"],
        [need_tar_xz, tar_xz_file, "J"]
      ].each do |need, file, flag|
        if need
          task package: ["#{package_dir}/#{file}"]
          file "#{package_dir}/#{file}" =>
            [package_dir_path] + package_files do
            chdir(package_dir) do
              sh @tar_command, "#{flag}cvf", file, package_name
            end
          end
        end
      end

      if need_zip
        task package: ["#{package_dir}/#{zip_file}"]
        file "#{package_dir}/#{zip_file}" =>
          [package_dir_path] + package_files do
          chdir(package_dir) do
            sh @zip_command, "-r", zip_file, package_name
          end
        end
      end

      directory package_dir_path => @package_files do
        @package_files.each do |fn|
          f = File.join(package_dir_path, fn)
          fdir = File.dirname(f)
          mkdir_p(fdir) unless File.exist?(fdir)
          if File.directory?(fn)
            mkdir_p(f)
          else
            rm_f f
            safe_ln(fn, f)
          end
        end
      end
      self
    end

    # The name of this package

    def package_name
      @version ? "#{@name}-#{@version}" : @name
    end

    # The directory this package will be built in

    def package_dir_path
      "#{package_dir}/#{package_name}"
    end

    # The package name with .tgz added

    def tgz_file
      "#{package_name}.tgz"
    end

    # The package name with .tar.gz added

    def tar_gz_file
      "#{package_name}.tar.gz"
    end

    # The package name with .tar.bz2 added

    def tar_bz2_file
      "#{package_name}.tar.bz2"
    end

    # The package name with .tar.xz added

    def tar_xz_file
      "#{package_name}.tar.xz"
    end

    # The package name with .zip added

    def zip_file
      "#{package_name}.zip"
    end
  end

end
