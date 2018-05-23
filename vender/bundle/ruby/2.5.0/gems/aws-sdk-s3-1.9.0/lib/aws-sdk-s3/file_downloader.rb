require 'pathname'
require 'thread'
require 'set'
require 'tmpdir'

module Aws
  module S3
    # @api private
    class FileDownloader

      MIN_CHUNK_SIZE = 5 * 1024 * 1024
      MAX_PARTS = 10_000
      THREAD_COUNT = 10

      def initialize(options = {})
        @client = options[:client] || Client.new
      end

      # @return [Client]
      attr_reader :client

      def download(destination, options = {})
        @path = destination
        @mode = options[:mode] || "auto"
        @thread_count = options[:thread_count] || THREAD_COUNT
        @chunk_size = options[:chunk_size]
        @bucket = options[:bucket]
        @key = options[:key]

        case @mode
        when "auto" then multipart_download
        when "single_request" then single_request
        when "get_range"
          if @chunk_size
            resp = @client.head_object(bucket: @bucket, key: @key)
            multithreaded_get_by_ranges(construct_chunks(resp.content_length))
          else
            msg = "In :get_range mode, :chunk_size must be provided"
            raise ArgumentError, msg
          end
        else
          msg = "Invalid mode #{@mode} provided, "\
            "mode should be :single_request, :get_range or :auto"
          raise ArgumentError, msg
        end
      end

      private

      def multipart_download
        resp = @client.head_object(bucket: @bucket, key: @key, part_number: 1)
        count = resp.parts_count
        if count.nil? || count <= 1
          resp.content_length < MIN_CHUNK_SIZE ?
            single_request :
            multithreaded_get_by_ranges(construct_chunks(resp.content_length))
        else
          # partNumber is an option
          resp = @client.head_object(bucket: @bucket, key: @key)
          resp.content_length < MIN_CHUNK_SIZE ?
            single_request :
            compute_mode(resp.content_length, count)
        end
      end

      def compute_mode(file_size, count)
        chunk_size = compute_chunk(file_size)
        part_size = (file_size.to_f / count.to_f).ceil
        if chunk_size < part_size
          multithreaded_get_by_ranges(construct_chunks(file_size))
        else
          multithreaded_get_by_parts(count)
        end
      end

      def construct_chunks(file_size)
        offset = 0
        default_chunk_size = compute_chunk(file_size)
        chunks = []
        while offset <= file_size
          progress = offset + default_chunk_size
          chunks << "bytes=#{offset}-#{progress < file_size ? progress : file_size}"
          offset = progress + 1
        end
        chunks
      end

      def compute_chunk(file_size)
        if @chunk_size && @chunk_size > file_size
          raise ArgumentError, ":chunk_size shouldn't exceed total file size."
        else
          @chunk_size || [(file_size.to_f / MAX_PARTS).ceil, MIN_CHUNK_SIZE].max.to_i
        end
      end

      def batches(chunks, mode)
        chunks = (1..chunks) if mode.eql? 'part_number'
        chunks.each_slice(@thread_count).to_a
      end

      def multithreaded_get_by_ranges(chunks)
        thread_batches(chunks, 'range')
      end

      def multithreaded_get_by_parts(parts)
        thread_batches(parts, 'part_number')
      end

      def thread_batches(chunks, param)
        batches(chunks, param).each do |batch|
          threads = []
          batch.each do |chunk|
            threads << Thread.new do
              resp = @client.get_object(
                :bucket => @bucket,
                :key => @key,
                param.to_sym => chunk
              )
              write(resp)
            end
          end
          threads.each(&:join)
        end
      end

      def write(resp)
        range, _ = resp.content_range.split(" ").last.split("/")
        head, _ = range.split("-").map {|s| s.to_i}
        IO.write(@path, resp.body.read, head)
      end

      def single_request
        @client.get_object(
          bucket: @bucket, key: @key, response_target: @path
        )
      end
    end
  end
end
