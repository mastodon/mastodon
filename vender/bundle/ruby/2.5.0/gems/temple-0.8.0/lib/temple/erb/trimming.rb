module Temple
  module ERB
    # ERB trimming like in erubis
    # Deletes spaces around '<% %>' and leave spaces around '<%= %>'.
    # @api public
    class Trimming < Filter
      define_options trim: true

      def on_multi(*exps)
        exps = exps.each_with_index.map do |e,i|
          if e.first == :static && i > 0 && exps[i-1].first == :code
            [:static, e.last.lstrip]
          elsif e.first == :static && i < exps.size-1 && exps[i+1].first == :code
            [:static, e.last.rstrip]
          else
            e
          end
        end if options[:trim]
        [:multi, *exps]
      end
    end
  end
end
