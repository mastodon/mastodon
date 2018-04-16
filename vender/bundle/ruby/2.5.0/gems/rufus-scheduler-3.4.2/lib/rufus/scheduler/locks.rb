
require 'fileutils'


class Rufus::Scheduler

  #
  # A lock that can always be acquired
  #
  class NullLock

    # Locking is always successful.
    #
    def lock; true; end

    def locked?; true; end
    def unlock; true; end
  end

  #
  # The standard flock mechanism, with its own class thanks to @ecin
  #
  class FileLock

    attr_reader :path

    def initialize(path)

      @path = path.to_s
    end

    # Locking is successful if this Ruby process can create and lock
    # its lockfile (at the given path).
    #
    def lock

      return true if locked?

      @lockfile = nil

      FileUtils.mkdir_p(::File.dirname(@path))

      file = File.new(@path, File::RDWR | File::CREAT)
      locked = file.flock(File::LOCK_NB | File::LOCK_EX)

      return false unless locked

      now = Time.now

      file.print("pid: #{$$}, ")
      file.print("scheduler.object_id: #{self.object_id}, ")
      file.print("time: #{now}, ")
      file.print("timestamp: #{now.to_f}")
      file.flush

      @lockfile = file

      true
    end

    def unlock

      !! (@lockfile && @lockfile.flock(File::LOCK_UN))
    end

    def locked?

      !! (@lockfile && @lockfile.flock(File::LOCK_NB | File::LOCK_EX))
    end
  end
end

