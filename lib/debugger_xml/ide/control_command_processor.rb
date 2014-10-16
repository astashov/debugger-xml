module DebuggerXml
  module Ide
    class ControlCommandProcessor

      def initialize(interface, proxy)
        @interface = interface
        @proxy = proxy
      end

      def process_commands
        while input = @interface.read_command
          process_input(input)
        end
      rescue IOError, Errno::EPIPE
      rescue Exception
        @interface.print("INTERNAL ERROR!!! #{$!}\n") rescue nil
        @interface.print($!.backtrace.map { |l| "\t#{l}" }.join("\n")) rescue nil
      ensure
        @interface.close
      end

      def process_command(cmd)
        catch(:debug_error) do
          if matched_cmd = @proxy.control_commands(@interface).find { |c| c.match(cmd) }
            matched_cmd.execute
          else
            process_context_commands(cmd)
          end
        end
      end

    private

      def process_input(input)
        split_commands(input).each do |cmd|
          process_command(cmd)
        end
      end

      def process_context_commands(input)
        unless @proxy.handler.at_line?
          @interface.errmsg(@proxy.print("base.errors.no_suspended_thread", input: input))
          return
        end
        state = @proxy.build_command_processor_state(@interface)
        event_commands = @proxy.event_commands(state)
        catch(:debug_error) do
          if cmd = event_commands.find { |c| c.match(input) }
            if state.context.dead? && cmd.class.need_context
              @interface.print(@proxy.print("base.errors.command_unavailable"))
            else
              cmd.execute
            end
          else
            @interface.print(@proxy.print("base.errors.unknown_command", input: input))
          end
        end
        state.context.thread.run if state.proceed?
      end

      # Split commands like this:
      # split_commands("abc;def\\;ghi;jkl") => ["abc", "def;ghi", "jkl"]
      def split_commands(input)
        input.split(/(?<!\\);/).map { |e| e.gsub("\\;", ";") }
      end

    end
  end
end
