# frozen_string_literal: true
require "rake/cloneable"
require "rake/file_utils_ext"
require "rake/ext/string"

module Rake

  ##
  # A FileList is essentially an array with a few helper methods defined to
  # make file manipulation a bit easier.
  #
  # FileLists are lazy.  When given a list of glob patterns for possible files
  # to be included in the file list, instead of searching the file structures
  # to find the files, a FileList holds the pattern for latter use.
  #
  # This allows us to define a number of FileList to match any number of
  # files, but only search out the actual files when then FileList itself is
  # actually used.  The key is that the first time an element of the
  # FileList/Array is requested, the pending patterns are resolved into a real
  # list of file names.
  #
  class FileList

    include Cloneable

    # == Method Delegation
    #
    # The lazy evaluation magic of FileLists happens by implementing all the
    # array specific methods to call +resolve+ before delegating the heavy
    # lifting to an embedded array object (@items).
    #
    # In addition, there are two kinds of delegation calls.  The regular kind
    # delegates to the @items array and returns the result directly.  Well,
    # almost directly.  It checks if the returned value is the @items object
    # itself, and if so will return the FileList object instead.
    #
    # The second kind of delegation call is used in methods that normally
    # return a new Array object.  We want to capture the return value of these
    # methods and wrap them in a new FileList object.  We enumerate these
    # methods in the +SPECIAL_RETURN+ list below.

    # List of array methods (that are not in +Object+) that need to be
    # delegated.
    ARRAY_METHODS = (Array.instance_methods - Object.instance_methods).map(&:to_s)

    # List of additional methods that must be delegated.
    MUST_DEFINE = %w[inspect <=>]

    # List of methods that should not be delegated here (we define special
    # versions of them explicitly below).
    MUST_NOT_DEFINE = %w[to_a to_ary partition * <<]

    # List of delegated methods that return new array values which need
    # wrapping.
    SPECIAL_RETURN = %w[
      map collect sort sort_by select find_all reject grep
      compact flatten uniq values_at
      + - & |
    ]

    DELEGATING_METHODS = (ARRAY_METHODS + MUST_DEFINE - MUST_NOT_DEFINE).map(&:to_s).sort.uniq

    # Now do the delegation.
    DELEGATING_METHODS.each do |sym|
      if SPECIAL_RETURN.include?(sym)
        ln = __LINE__ + 1
        class_eval %{
          def #{sym}(*args, &block)
            resolve
            result = @items.send(:#{sym}, *args, &block)
            self.class.new.import(result)
          end
        }, __FILE__, ln
      else
        ln = __LINE__ + 1
        class_eval %{
          def #{sym}(*args, &block)
            resolve
            result = @items.send(:#{sym}, *args, &block)
            result.object_id == @items.object_id ? self : result
          end
        }, __FILE__, ln
      end
    end

    GLOB_PATTERN = %r{[*?\[\{]}

    # Create a file list from the globbable patterns given.  If you wish to
    # perform multiple includes or excludes at object build time, use the
    # "yield self" pattern.
    #
    # Example:
    #   file_list = FileList.new('lib/**/*.rb', 'test/test*.rb')
    #
    #   pkg_files = FileList.new('lib/**/*') do |fl|
    #     fl.exclude(/\bCVS\b/)
    #   end
    #
    def initialize(*patterns)
      @pending_add = []
      @pending = false
      @exclude_patterns = DEFAULT_IGNORE_PATTERNS.dup
      @exclude_procs = DEFAULT_IGNORE_PROCS.dup
      @items = []
      patterns.each { |pattern| include(pattern) }
      yield self if block_given?
    end

    # Add file names defined by glob patterns to the file list.  If an array
    # is given, add each element of the array.
    #
    # Example:
    #   file_list.include("*.java", "*.cfg")
    #   file_list.include %w( math.c lib.h *.o )
    #
    def include(*filenames)
      # TODO: check for pending
      filenames.each do |fn|
        if fn.respond_to? :to_ary
          include(*fn.to_ary)
        else
          @pending_add << Rake.from_pathname(fn)
        end
      end
      @pending = true
      self
    end
    alias :add :include

    # Register a list of file name patterns that should be excluded from the
    # list.  Patterns may be regular expressions, glob patterns or regular
    # strings.  In addition, a block given to exclude will remove entries that
    # return true when given to the block.
    #
    # Note that glob patterns are expanded against the file system. If a file
    # is explicitly added to a file list, but does not exist in the file
    # system, then an glob pattern in the exclude list will not exclude the
    # file.
    #
    # Examples:
    #   FileList['a.c', 'b.c'].exclude("a.c") => ['b.c']
    #   FileList['a.c', 'b.c'].exclude(/^a/)  => ['b.c']
    #
    # If "a.c" is a file, then ...
    #   FileList['a.c', 'b.c'].exclude("a.*") => ['b.c']
    #
    # If "a.c" is not a file, then ...
    #   FileList['a.c', 'b.c'].exclude("a.*") => ['a.c', 'b.c']
    #
    def exclude(*patterns, &block)
      patterns.each do |pat|
        if pat.respond_to? :to_ary
          exclude(*pat.to_ary)
        else
          @exclude_patterns << Rake.from_pathname(pat)
        end
      end
      @exclude_procs << block if block_given?
      resolve_exclude unless @pending
      self
    end

    # Clear all the exclude patterns so that we exclude nothing.
    def clear_exclude
      @exclude_patterns = []
      @exclude_procs = []
      self
    end

    # A FileList is equal through array equality.
    def ==(array)
      to_ary == array
    end

    # Return the internal array object.
    def to_a
      resolve
      @items
    end

    # Return the internal array object.
    def to_ary
      to_a
    end

    # Lie about our class.
    def is_a?(klass)
      klass == Array || super(klass)
    end
    alias kind_of? is_a?

    # Redefine * to return either a string or a new file list.
    def *(other)
      result = @items * other
      case result
      when Array
        self.class.new.import(result)
      else
        result
      end
    end

    def <<(obj)
      resolve
      @items << Rake.from_pathname(obj)
      self
    end

    # Resolve all the pending adds now.
    def resolve
      if @pending
        @pending = false
        @pending_add.each do |fn| resolve_add(fn) end
        @pending_add = []
        resolve_exclude
      end
      self
    end

    def resolve_add(fn) # :nodoc:
      case fn
      when GLOB_PATTERN
        add_matching(fn)
      else
        self << fn
      end
    end
    private :resolve_add

    def resolve_exclude # :nodoc:
      reject! { |fn| excluded_from_list?(fn) }
      self
    end
    private :resolve_exclude

    # Return a new FileList with the results of running +sub+ against each
    # element of the original list.
    #
    # Example:
    #   FileList['a.c', 'b.c'].sub(/\.c$/, '.o')  => ['a.o', 'b.o']
    #
    def sub(pat, rep)
      inject(self.class.new) { |res, fn| res << fn.sub(pat, rep) }
    end

    # Return a new FileList with the results of running +gsub+ against each
    # element of the original list.
    #
    # Example:
    #   FileList['lib/test/file', 'x/y'].gsub(/\//, "\\")
    #      => ['lib\\test\\file', 'x\\y']
    #
    def gsub(pat, rep)
      inject(self.class.new) { |res, fn| res << fn.gsub(pat, rep) }
    end

    # Same as +sub+ except that the original file list is modified.
    def sub!(pat, rep)
      each_with_index { |fn, i| self[i] = fn.sub(pat, rep) }
      self
    end

    # Same as +gsub+ except that the original file list is modified.
    def gsub!(pat, rep)
      each_with_index { |fn, i| self[i] = fn.gsub(pat, rep) }
      self
    end

    # Apply the pathmap spec to each of the included file names, returning a
    # new file list with the modified paths.  (See String#pathmap for
    # details.)
    def pathmap(spec=nil, &block)
      collect { |fn| fn.pathmap(spec, &block) }
    end

    # Return a new FileList with <tt>String#ext</tt> method applied to
    # each member of the array.
    #
    # This method is a shortcut for:
    #
    #    array.collect { |item| item.ext(newext) }
    #
    # +ext+ is a user added method for the Array class.
    def ext(newext="")
      collect { |fn| fn.ext(newext) }
    end

    # Grep each of the files in the filelist using the given pattern. If a
    # block is given, call the block on each matching line, passing the file
    # name, line number, and the matching line of text.  If no block is given,
    # a standard emacs style file:linenumber:line message will be printed to
    # standard out.  Returns the number of matched items.
    def egrep(pattern, *options)
      matched = 0
      each do |fn|
        begin
          open(fn, "r", *options) do |inf|
            count = 0
            inf.each do |line|
              count += 1
              if pattern.match(line)
                matched += 1
                if block_given?
                  yield fn, count, line
                else
                  puts "#{fn}:#{count}:#{line}"
                end
              end
            end
          end
        rescue StandardError => ex
          $stderr.puts "Error while processing '#{fn}': #{ex}"
        end
      end
      matched
    end

    # Return a new file list that only contains file names from the current
    # file list that exist on the file system.
    def existing
      select { |fn| File.exist?(fn) }.uniq
    end

    # Modify the current file list so that it contains only file name that
    # exist on the file system.
    def existing!
      resolve
      @items = @items.select { |fn| File.exist?(fn) }.uniq
      self
    end

    # FileList version of partition.  Needed because the nested arrays should
    # be FileLists in this version.
    def partition(&block)       # :nodoc:
      resolve
      result = @items.partition(&block)
      [
        self.class.new.import(result[0]),
        self.class.new.import(result[1]),
      ]
    end

    # Convert a FileList to a string by joining all elements with a space.
    def to_s
      resolve
      self.join(" ")
    end

    # Add matching glob patterns.
    def add_matching(pattern)
      self.class.glob(pattern).each do |fn|
        self << fn unless excluded_from_list?(fn)
      end
    end
    private :add_matching

    # Should the given file name be excluded from the list?
    #
    # NOTE: This method was formerly named "exclude?", but Rails
    # introduced an exclude? method as an array method and setup a
    # conflict with file list. We renamed the method to avoid
    # confusion. If you were using "FileList#exclude?" in your user
    # code, you will need to update.
    def excluded_from_list?(fn)
      return true if @exclude_patterns.any? do |pat|
        case pat
        when Regexp
          fn =~ pat
        when GLOB_PATTERN
          flags = File::FNM_PATHNAME
          # Ruby <= 1.9.3 does not support File::FNM_EXTGLOB
          flags |= File::FNM_EXTGLOB if defined? File::FNM_EXTGLOB
          File.fnmatch?(pat, fn, flags)
        else
          fn == pat
        end
      end
      @exclude_procs.any? { |p| p.call(fn) }
    end

    DEFAULT_IGNORE_PATTERNS = [
      /(^|[\/\\])CVS([\/\\]|$)/,
      /(^|[\/\\])\.svn([\/\\]|$)/,
      /\.bak$/,
      /~$/
    ]
    DEFAULT_IGNORE_PROCS = [
      proc { |fn| fn =~ /(^|[\/\\])core$/ && ! File.directory?(fn) }
    ]

    def import(array) # :nodoc:
      @items = array
      self
    end

    class << self
      # Create a new file list including the files listed. Similar to:
      #
      #   FileList.new(*args)
      def [](*args)
        new(*args)
      end

      # Get a sorted list of files matching the pattern. This method
      # should be preferred to Dir[pattern] and Dir.glob(pattern) because
      # the files returned are guaranteed to be sorted.
      def glob(pattern, *args)
        Dir.glob(pattern, *args).sort
      end
    end
  end
end

module Rake
  class << self

    # Yield each file or directory component.
    def each_dir_parent(dir)    # :nodoc:
      old_length = nil
      while dir != "." && dir.length != old_length
        yield(dir)
        old_length = dir.length
        dir = File.dirname(dir)
      end
    end

    # Convert Pathname and Pathname-like objects to strings;
    # leave everything else alone
    def from_pathname(path)    # :nodoc:
      path = path.to_path if path.respond_to?(:to_path)
      path = path.to_str if path.respond_to?(:to_str)
      path
    end
  end
end # module Rake
