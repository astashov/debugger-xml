require 'debugger/xml/ide/control_command_processor'

module Debugger
  module Xml
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
end

