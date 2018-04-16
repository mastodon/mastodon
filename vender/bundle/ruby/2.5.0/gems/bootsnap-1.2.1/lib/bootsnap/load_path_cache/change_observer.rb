module Bootsnap
  module LoadPathCache
    module ChangeObserver
      def self.register(observer, arr)
        # Re-overriding these methods on an array that already has them would
        # cause StackOverflowErrors
        return if arr.respond_to?(:push_without_lpc)

        # For each method that adds items to one end or another of the array
        # (<<, push, unshift, concat), override that method to also notify the
        # observer of the change.
        sc = arr.singleton_class
        sc.send(:alias_method, :shovel_without_lpc, :<<)
        arr.define_singleton_method(:<<) do |entry|
          observer.push_paths(self, entry.to_s)
          shovel_without_lpc(entry)
        end

        sc.send(:alias_method, :push_without_lpc, :push)
        arr.define_singleton_method(:push) do |*entries|
          observer.push_paths(self, *entries.map(&:to_s))
          push_without_lpc(*entries)
        end

        sc.send(:alias_method, :unshift_without_lpc, :unshift)
        arr.define_singleton_method(:unshift) do |*entries|
          observer.unshift_paths(self, *entries.map(&:to_s))
          unshift_without_lpc(*entries)
        end

        sc.send(:alias_method, :concat_without_lpc, :concat)
        arr.define_singleton_method(:concat) do |entries|
          observer.push_paths(self, *entries.map(&:to_s))
          concat_without_lpc(entries)
        end

        # For each method that modifies the array more aggressively, override
        # the method to also have the observer completely reconstruct its state
        # after the modification. Many of these could be made to modify the
        # internal state of the LoadPathCache::Cache more efficiently, but the
        # accounting cost would be greater than the hit from these, since we
        # actively discourage calling them.
        %i(
          collect! compact! delete delete_at delete_if fill flatten! insert map!
          reject! reverse! select! shuffle! shift slice! sort! sort_by!
        ).each do |meth|
          sc.send(:alias_method, :"#{meth}_without_lpc", meth)
          arr.define_singleton_method(meth) do |*a|
            send(:"#{meth}_without_lpc", *a)
            observer.reinitialize
          end
        end
      end
    end
  end
end
