module RRR
  module CLI
    def self.start(args)
      pattern = Pattern.new(args.first)
      p pattern.expr

      program = Program.from_string(STDIN.read)

      program.filter(pattern).each do |m|
        m.print(STDOUT)
      end
    end
  end
end
