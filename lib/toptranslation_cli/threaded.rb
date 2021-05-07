# frozen_string_literal: true

module Enumerable
  def in_chunks(chunks, flatten: false)
    chunk_size = [size, (size / chunks.to_f).ceil].select(&:positive?).min
    chunked = each_slice(chunk_size)

    chunked = chunked.map(&:flatten) if flatten
    chunked
  end

  def each_in_threads(num_threads, flatten: false, &block)
    in_chunks(num_threads, flatten).map do |chunk|
      Thread.new do
        chunk.each(&block)
      end
    end.each(&:join)
  end
end
