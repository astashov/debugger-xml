if Object.const_defined?("Byebug")
  module DebuggerXml
    class ByebugProxy
      include Byebug::FileFunctions

      def start
        ::Byebug.start
      end

      def handler
        ::Byebug.handler
      end

      def handler=(value)
        ::Byebug.handler = value
      end

      def control_commands(interface)
        control_command_classes = commands.select(&:allow_in_control)
        state = ::Byebug::ControlState.new(interface)
        control_command_classes.map { |cmd| cmd.new(state) }
      end

      def build_command_processor_state(interface)
        ::Byebug::RegularXmlState.new(handler.context, [], handler.file, interface, handler.line)
      end

      def commands
        ::Byebug::Command.commands
      end

      def event_commands(state)
        event_command_classes.map { |cls| cls.new(state) }
      end

      def print(*args)
        printer.print(*args)
      end

      def canonic_file(file)
        normalize(file)
      end

      def line_at(file, line)
      end

      def breakpoints
        ::Byebug.breakpoints
      end

      def debug_thread?(context)
        context && context.thread.is_a?(debug_thread_class)
      end

      def debug_thread_class
        ::Byebug::DebugThread
      end

      def current_context
        ::Byebug.current_context
      end

      def set_rdebug_script(file)
        ::Byebug.const_set("RDEBUG_SCRIPT", file)
      end

      def set_prog_script(file)
        ::Byebug.const_set("PROG_SCRIPT", file)
      end

      def set_argv(argv)
        ::Byebug.const_set("ARGV", argv)
      end

      def interrupt_last
        ::Byebug.interrupt_last
      end

      def tracing=(value)
        ::Byebug.tracing = value
      end

      def wait_connection=(value)
        ::Byebug.wait_connection = value
      end

      def printer=(value)
        ::Byebug.printer = value
      end

      def debug_load
        ::Byebug.debug_load(::Byebug::PROG_SCRIPT, false)
      end

      def inspect_command_class
        ::Byebug::InspectCommand
      end

      private

      def event_command_classes
        commands
      end

      def printer
        ::Byebug.printer
      end

    end
  end
end
