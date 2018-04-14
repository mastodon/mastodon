# Monkey patch to show milliseconds
module Benchmark
  module IPS
    class Report
      module EntryExtension
        def body
          return super if Benchmark::IPS.options[:format] != :human

          left = "%s i/s (%1.3fms)" % [Helpers.scale(ips), (1000.0 / ips)]
          iters = Helpers.scale(@iterations)

          if @show_total_time
            left.ljust(20) + (" - %s in %10.6fs" % [iters, runtime])
          else
            left.ljust(20) + (" - %s" % iters)
          end
        end
      end
      Entry.prepend(EntryExtension)
    end
  end

  module CompareExtension
    def compare(*reports)
      return if reports.size < 2

      sorted = reports.sort_by(&:ips).reverse
      best = sorted.shift
      $stdout.puts "\nComparison:"
      $stdout.printf "%20s: %10.1f i/s (%1.3fms)\n", best.label, best.ips, (1000.0 / best.ips)

      sorted.each do |report|
        name = report.label.to_s

        x = (best.ips.to_f / report.ips.to_f)
        $stdout.printf "%20s: %10.1f i/s (%1.3fms) - %.2fx slower\n", name, report.ips, (1000.0 / report.ips), x
      end

      $stdout.puts
    end
  end
  extend CompareExtension
end
