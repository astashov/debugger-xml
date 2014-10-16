require 'debugger_xml/ide/control_command_processor'

module DebuggerXml
  module Vim

    class ControlCommandProcessor < Ide::ControlCommandProcessor
      private

        def process_input(input)
          super(input)
          @interface.send_response
        end

    end
  end
end
