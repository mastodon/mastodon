class UndergroundMap
  attr_reader :stops, :total_num_lines

  PALETTE = %w(
    64AC7A
    A9CE69
    CFD788
    B95B38
  ).freeze

  class Stop
    attr_reader :id

    attr_accessor :num_departures, :arriving_line,
                  :bypassing_lines, :departing_lines,
                  :max_num_of_lines

    def initialize(id, has_arrival = false)
      @id               = id
      @has_arrival      = has_arrival
      @num_departures   = 0
      @arriving_line    = nil
      @bypassing_lines  = []
      @departing_lines  = []
      @max_num_of_lines = 0
    end

    def arrival?
      @has_arrival
    end

    def outgoing_lines?
      !(@bypassing_lines.empty? && @departing_lines.empty?)
    end
  end

  def initialize
    @stops           = []
    @index_map       = {}
    @total_num_lines = 0
  end

  def add_stop(id, previous_stop = nil)
    @index_map[id] = @stops.size

    if previous_stop
      @stops << Stop.new(id, true)
      @stops[@index_map[previous_stop]].num_departures += 1
    else
      @stops << Stop.new(id)
    end
  end

  def find_stop(id)
    @stops[@index_map[id]]
  end

  def color(line)
    PALETTE[line % PALETTE.size]
  end

  def calculate_lines!
    lines = []
    next_line = 0

    @stops.each do |stop|
      if stop.arrival?
        arrival = lines.pop

        stop.arriving_line   = arrival
        stop.bypassing_lines = lines.dup

        unless stop.num_departures.zero?
          new_next_line = next_line + stop.num_departures - 1
          stop.departing_lines = (next_line...new_next_line).to_a.reverse
          stop.departing_lines << arrival
          next_line = new_next_line
        end
      else
        stop.arriving_line   = nil
        stop.bypassing_lines = lines.dup

        new_next_line = next_line + stop.num_departures
        stop.departing_lines = (next_line...new_next_line).to_a.reverse
        next_line = new_next_line
      end

      lines.concat(stop.departing_lines)
    end

    @total_num_lines = next_line

    @stops.each do |stop|
      stop.max_num_of_lines = @total_num_lines
    end
  end
end
