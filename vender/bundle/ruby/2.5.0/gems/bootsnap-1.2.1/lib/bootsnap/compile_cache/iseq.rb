require 'bootsnap/bootsnap'
require 'zlib'

module Bootsnap
  module CompileCache
    module ISeq
      class << self
        attr_accessor :cache_dir
      end

      def self.input_to_storage(_, path)
        RubyVM::InstructionSequence.compile_file(path).to_binary
      rescue SyntaxError
        raise Uncompilable, 'syntax error'
      end

      def self.storage_to_output(binary)
        RubyVM::InstructionSequence.load_from_binary(binary)
      rescue RuntimeError => e
        if e.message == 'broken binary format'
          STDERR.puts "[Bootsnap::CompileCache] warning: rejecting broken binary"
          return nil
        else
          raise
        end
      end

      def self.input_to_output(_)
        nil # ruby handles this
      end

      module InstructionSequenceMixin
        def load_iseq(path)
          # Having coverage enabled prevents iseq dumping/loading.
          return nil if defined?(Coverage) && Bootsnap::CompileCache::Native.coverage_running?

          Bootsnap::CompileCache::Native.fetch(
            Bootsnap::CompileCache::ISeq.cache_dir,
            path.to_s,
            Bootsnap::CompileCache::ISeq
          )
        rescue RuntimeError => e
          if e.message =~ /unmatched platform/
            puts "unmatched platform for file #{path}"
          end
          raise
        end

        def compile_option=(hash)
          super(hash)
          Bootsnap::CompileCache::ISeq.compile_option_updated
        end
      end

      def self.compile_option_updated
        option = RubyVM::InstructionSequence.compile_option
        crc = Zlib.crc32(option.inspect)
        Bootsnap::CompileCache::Native.compile_option_crc32 = crc
      end

      def self.install!(cache_dir)
        Bootsnap::CompileCache::ISeq.cache_dir = cache_dir
        Bootsnap::CompileCache::ISeq.compile_option_updated
        class << RubyVM::InstructionSequence
          prepend InstructionSequenceMixin
        end
      end
    end
  end
end
