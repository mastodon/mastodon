# frozen_string_literal: true

# Event based timers:

# Serviced 31812 events in 2.39075272 seconds, 13306.320832794887 e/s.
# Thread ID: 7336700
# Fiber ID: 30106340
# Total: 2.384043
# Sort by: self_time

# %self      total      self      wait     child     calls  name
# 13.48      0.510     0.321     0.000     0.189    369133  Timers::Events::Handle#<=>
#  8.12      0.194     0.194     0.000     0.000    427278  Timers::Events::Handle#to_f
#  4.55      0.109     0.109     0.000     0.000    427278  Float#<=>
#  4.40      1.857     0.105     0.000     1.752    466376 *Timers::Events#bsearch
#  4.30      0.103     0.103     0.000     0.000    402945  Float#to_f
#  2.65      0.063     0.063     0.000     0.000     33812  Array#insert
#  2.64      1.850     0.063     0.000     1.787     33812  Timers::Events#schedule
#  2.40      1.930     0.057     0.000     1.873     33812  Timers::Timer#reset
#  1.89      1.894     0.045     0.000     1.849     31812  Timers::Timer#fire
#  1.69      1.966     0.040     0.000     1.926     31812  Timers::Events::Handle#fire
#  1.35      0.040     0.032     0.000     0.008     33812  Timers::Events::Handle#initialize
#  1.29      0.044     0.031     0.000     0.013     44451  Timers::Group#current_offset

# SortedSet based timers:

# Serviced 32516 events in 66.753277275 seconds, 487.1072288781219 e/s.
# Thread ID: 15995640
# Fiber ID: 38731780
# Total: 66.716394
# Sort by: self_time

# %self      total      self      wait     child     calls  name
# 54.73     49.718    36.513     0.000    13.205  57084873  Timers::Timer#<=>
# 23.74     65.559    15.841     0.000    49.718     32534  Array#sort!
# 19.79     13.205    13.205     0.000     0.000  57084873  Float#<=>

# Max out events performance (on my computer):
# Serviced 1142649 events in 11.194903921 seconds, 102068.70405115146 e/s.

RSpec.describe Timers::Group do
  it "runs efficiently" do
    result = []
    range = (1..500)
    duration = 2.0

    total = 0
    range.each do |index|
      offset = index.to_f / range.max
      total += (duration / offset).floor

      subject.every(index.to_f / range.max, :strict) { result << index }
    end

    subject.wait while result.size < total

    rate = result.size.to_f / subject.current_offset
    puts "Serviced #{result.size} events in #{subject.current_offset} seconds, #{rate} e/s."

    expect(subject.current_offset).to be_within(TIMER_QUANTUM).of(duration)
  end

  #   it "runs efficiently at high volume" do
  #     results = []
  #     range = (1..300)
  #     groups = (1..20)
  #     duration = 101
  #
  #     timers = []
  #     @mutex = Mutex.new
  #     start = Time.now
  #     groups.each do |gi|
  #       timers << Thread.new {
  #         result = []
  #         timer = Timers::Group.new
  #         total = 0
  #         range.each do |ri|
  #           offset = ri.to_f / range.max
  #           total += (duration / offset).floor
  #           timer.every(ri.to_f / range.max, :strict) { result << ri }
  #         end
  #         timer.wait while result.size < total
  #         @mutex.synchronize { results += result }
  #
  #       }
  #     end
  #     timers.each { |t| t.join }
  #     finish = Time.now
  #
  #     rate = results.size.to_f / ( runtime = finish - start )
  #
  #     puts "Serviced #{results.size} events in #{runtime} seconds, #{rate} e/s; across #{groups.max} timers."
  #
  #     expect(runtime).to be_within(TIMER_QUANTUM).of(duration)
  #   end
end
