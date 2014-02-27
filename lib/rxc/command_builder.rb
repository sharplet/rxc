module RXC

  class CommandBuilder
    attr_reader :pipeline

    def initialize
      @pipeline = []
      yield self if block_given?
    end

    def add(callable=nil, &block)
      pipeline.push(callable || block)
    end

    def to_s
      cmd = pipeline.reduce([]) {|cmd, step|
        args = []
        args << cmd if step.arity == 1
        cmd.push(step.call(*args))
      }
      cmd.join(' ').strip
    end
  end

end
