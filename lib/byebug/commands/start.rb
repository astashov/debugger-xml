module Byebug
  class StartCommand < Command # :nodoc:
    self.allow_in_control = true

    def regexp
      /^\s*(start)\s*$/ix
    end

    def execute
      DebuggerXml.proceed
    end

    class << self
      def help_command
        'start'
      end

      def help(cmd)
        %{
          run prog script
        }
      end
    end
  end
end
