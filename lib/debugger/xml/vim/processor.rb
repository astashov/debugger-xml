require 'ruby-debug/processor'

module Debugger
  module Xml
    module Vim

      class Processor < Ide::Processor
        private
          def stop_thread
            processor = Vim::ControlCommandProcessor.new(@interface)
            processor.process_command("where")
            processor.process_command("var local")
            @interface.send_response
            super
          end
      end

    end
  end
end

