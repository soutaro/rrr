module RRR
  class Match
    attr_reader :line

    def initialize(source, file, line)
      @source = source
      @file = file
      @line = line
    end

    def print(out)
      out.puts "#{@file}:#{@line}\t#{@source.lines[line-1]}"
    end
  end
end
