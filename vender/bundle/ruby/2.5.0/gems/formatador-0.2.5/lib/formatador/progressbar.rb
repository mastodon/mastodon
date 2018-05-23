require 'thread'

class Formatador

  class ProgressBar

    attr_accessor :current, :total, :opts

    def initialize(total, opts = {}, &block)
      @current = opts.delete(:start) || 0
      @total   = total.to_i
      @opts    = opts
      @lock    = Mutex.new
      @complete_proc = block_given? ? block : Proc.new { }
    end

    def increment(increment = 1)
      @lock.synchronize do
        return if complete?
        @current += increment.to_i
        @complete_proc.call(self) if complete?
        Formatador.redisplay_progressbar(current, total, opts)
      end
    end

    private

      def complete?
        current == total
      end

  end

  def redisplay_progressbar(current, total, options = {})
    options = { :color => 'white', :width => 50, :new_line => true }.merge!(options)
    data = progressbar(current, total, options)
    if current < total
      redisplay(data, options[:width])
    else
      redisplay("#{data}", options[:width])
      if options[:new_line]
        new_line
      end
      @progressbar_started_at = nil
    end
  end

  private

  def progressbar(current, total, options)
    color = options[:color]
    started_at = options[:started_at]
    width = options[:width]

    output = []

    if options[:label]
      output << options[:label]
    end

    # width
    # we are going to write a string that looks like "   current/total"
    # It would be nice if it were left padded with spaces in such a way that
    # it puts the progress bar in a constant place on the page. This witdh
    # calculation allows for the "current" string to be up to two characters
    # longer than the "total" string without problems. eg- current =
    # 9.99, total = 10
    padding = total.to_s.size * 2 + 3

    output << "[#{color}]%#{padding}s[/]" % "#{current}/#{total}"

    percent = current.to_f / total.to_f
    percent = 0 if percent < 0
    percent = 1 if percent > 1

    done = '*' * (percent * width).ceil
    remaining = ' ' * (width - done.length)
    output << "[_white_]|[/][#{color}][_#{color}_]#{done}[/]#{remaining}[_white_]|[/]"

    if started_at
      elapsed = Time.now - started_at
      minutes = (elapsed / 60).truncate.to_s
      seconds = (elapsed % 60).truncate.to_s
      output << "#{minutes}:#{'0' if seconds.size < 2}#{seconds}"
    end

    output << ''
    output.join('  ')
  end

end
