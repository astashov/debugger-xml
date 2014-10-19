require 'debugger_xml/ide/control_command_processor'

module DebuggerXml
  module Vim

    class ControlCommandProcessor < Ide::ControlCommandProcessor
      def initialize(*args)
        super(*args)
        @mutex = Mutex.new
      end

      def process_command(*args)
        @mutex.synchronize do
          super(*args)
          @interface.send_response
        end
      end
    end
  end
end
