module RRR
  class Program
    def initialize(expr, file, source)
      @expr = expr
      @file = file
      @source = source
    end

    def self.from_string(string)
      new(RubyParser.new.parse(string), "-", string)
    end

    def filter(pattern)
      matches = []

      self.each_subexp do |exp|
        #p exp

        if pattern =~ exp
          matches << Match.new(@source, @file, exp.line)
        end
      end

      matches
    end

    def each_subexp(e = @expr, &block)
      e.deep_each &block
    end
  end
end
