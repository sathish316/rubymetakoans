module EdgeCase

  class << self
    def simple_output; false; end
  end

  module Color
    module_function
    COLORS = {
      :clear   => 0,  :black   => 30, :red   => 31,
      :green   => 32, :yellow  => 33, :blue  => 34,
      :magenta => 35, :cyan    => 36,
    }

    def method_missing(method_name,string)
      "<div style='color:#{method_name};'>\#\{string\}</div>"
    end

  end
  class Koan
    def self.command_line(args)
      #do nothing
    end
  end

  class Sensei
    attr_reader :instructions

    def puts(message='')
      instructions << message unless (message.nil? || message.start_with?('Please meditate'))
    end

    def progress
      [5]
    end

    def instructions
      @instructions ||= []
    end

    def indent(text)
      text = text.split(/\n/) if text.is_a?(String)
      [text].flatten.collect{|t| "  #{t}"}
    end

    def observe(step)
      if step.passed?
        @pass_count += 1
        if @pass_count > progress.last.to_i
          # @observations << Color.green("#{step.koan_file}##{step.name} has expanded your awareness.")
        end
      else
        # @failed_test = step
        failures[step.name] = step.failure
        # add_progress(@pass_count)
        # @observations << Color.red("#{step.koan_file}##{step.name} has damaged your karma.")
        # throw :edgecase_exit
      end
    end
    def guide_through_error
      # puts "The answers you seek..."
      # puts Color.red(indent(failure.message).join)
    end
    def failures
      @failures ||= {}
    end

    def embolden_first_line_only(text)
      # do not print stacktrace
    end
  end

  class ThePath
    attr_accessor :sensei
    def walk
      #do nothing
    end
    def online_walk
      @sensei = EdgeCase::Sensei.new
      each_step do |step|
        @sensei.observe(step.meditate)
      end
      sensei.instruct
    end
  end
end
