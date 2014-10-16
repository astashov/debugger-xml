module DebuggerXml
  class DebuggerProxy
    def start
      ::Debugger.start
    end

    def handler
      ::Debugger.handler
    end

    def handler=(value)
      ::Debugger.handler = value
    end

    def control_commands(interface)
      control_command_classes = commands.select(&:allow_in_control)
      state = ::Debugger::ControlCommandProcessor::State.new(interface, control_command_classes)
      control_command_classes.map { |cmd| cmd.new(state) }
    end

    def build_command_processor_state(interface)
      ::Debugger::CommandProcessor::State.new do |s|
        s.context = handler.context
        s.file    = handler.file
        s.line    = handler.line
        s.binding = handler.context.frame_binding(0)
        s.interface = interface
        s.commands = event_command_classes
      end
    end

    def commands
      ::Debugger::Command.commands
    end

    def event_commands(state)
      event_command_classes.map { |cls| cls.new(state) }
    end

    def print(*args)
      printer.print(*args)
    end

    def canonic_file(file)
      ::Debugger::CommandProcessor.canonic_file(file)
    end

    def line_at(file, line)
      ::Debugger.line_at(file, line)
    end

    def breakpoints
      ::Debugger.breakpoints
    end

    def debug_thread?(context)
      context && context.thread.is_a?(debug_thread_class)
    end

    def debug_thread_class
      ::Debugger::DebugThread
    end

    def current_context
      ::Debugger.current_context
    end

    def set_rdebug_script(file)
      ::Debugger.const_set("RDEBUG_SCRIPT", file)
    end

    def set_prog_script(file)
      ::Debugger.const_set("PROG_SCRIPT", file)
    end

    def set_argv(argv)
      ::Debugger.const_set("ARGV", argv)
    end

    def interrupt_last
      ::Debugger.interrupt_last
    end

    def tracing=(value)
      ::Debugger.tracing = value
    end

    def wait_connection=(value)
      ::Debugger.wait_connection = value
    end

    def printer=(value)
      ::Debugger.printer = value
    end

    def debug_load
      ::Debugger.debug_load(::Debugger::PROG_SCRIPT, false, false)
    end

    def inspect_command_class
      ::Debugger::InspectCommand
    end

    private

    def event_command_classes
      commands.select(&:event)
    end

    def printer
      ::Debugger.printer
    end

  end
end
