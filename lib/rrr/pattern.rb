module RRR
  class Pattern
    attr_reader :expr

    def initialize(string)
      @count = 0
      @vars = Set.new
      @seqs = Set.new

      string = string.gsub(/(##)|(#\*#)/) do |hash|
        fresh_var(hash)
      end

      @expr = RubyParser.new.parse(string)
    end

    def =~(e)
      test(self.expr, e)
    end

    private

    def fresh_var(hash)
      @count += 1

      if hash == "##"
        var = "rrr___var___#{@count}".to_sym
        @vars << var
      end

      if hash == "#*#"
        var = "rrr___seq___#{@count}".to_sym
        @seqs << var
      end

      var
    end

    def test(pat, expr)
      return true if pat == nil && expr == nil
      return false if pat == nil || expr == nil

      case
        when any?(pat)
          true

        when call_any?(pat)
          expr.first == :call && test(pat[1], expr[1]) && pat[2] == expr[2]

        when pat.first == :defn && any_args?(pat[2]) && expr.first == :defn
          pat[1] == expr[1] && test_def_body(pat, expr)

        when pat.first == :defn && expr.first == :defn && pat[1] == expr[1]
          test(pat[2], expr[2]) && test_def_body(pat, expr)

        when pat.first == :args && expr.first == :args && pat.size == expr.size
          pairs = pat.zip(expr)
          pairs[1, pairs.size-1].all? {|p, e| @vars.include?(p) || p == e }

        when vcall?(pat) && expr.first == :lvar
          pat[2] == expr.last

        when pat.size == expr.size
          pat.zip(expr).all? {|p, e|
            if p.is_a?(Sexp) && e.is_a?(Sexp)
              test(p, e)
            else
              p == e
            end
          }

        else
          false
      end
    end

    def all_sexp_pairs?(a1, a2, &block)
      a1.zip(a2).all? {|e1, e2|
        if e1.is_a?(Sexp) && e2.is_a?(Sexp)
          yield(e1, e2)
        else
          true
        end
      }
    end

    def test_def_body(pat, expr)
      case
        when pat.size == 4 && any?(pat.last)
          true
        when pat.size == expr.size
          all_sexp_pairs?(pat[3, pat.size-1], expr[3, expr.size-1]) {|p1, e1| test(p1, e1) }
        else
          false
      end
    end

    def vcall?(pat)
      pat.first == :call && pat[1] == nil && pat.size == 3
    end

    def call_any?(pat)
      pat.first == :call && pat.size == 4 && seq?(pat.last)
    end

    def seq?(pat)
      vcall?(pat) && @seqs.include?(pat[2])
    end

    def any?(pat)
      vcall?(pat) && @vars.include?(pat[2])
    end

    def any_args?(pat)
      pat.first == :args && pat.size == 2 && @seqs.include?(pat.last)
    end
  end
end
