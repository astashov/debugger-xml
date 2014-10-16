require 'debugger_xml/ide/processor'

module DebuggerXml
  module Vim

    class Processor < Ide::Processor
      private
        def stop_thread
          processor = Vim::ControlCommandProcessor.new(@interface, @proxy)
          processor.process_command("where")
          processor.process_command("var local")
          @interface.send_response
          super
        end
    end

  end
end
