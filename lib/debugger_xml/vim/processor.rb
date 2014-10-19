require 'debugger_xml/ide/processor'

module DebuggerXml
  module Vim

    class Processor < Ide::Processor
      def initialize(control_command_processor, *args)
        @control_command_processor = control_command_processor
        super(*args)
      end

      def stop_thread
        @control_command_processor.process_command("where")
        @control_command_processor.process_command("var ide")
        super
      end
    end

  end
end
