module Debugger
  module Xml
    module Ide

      class ControlCommandProcessor < Debugger::Processor

        def initialize(interface)
          @interface = interface
        end

        def process_commands
          while input = @interface.read_command
            process_input(input)
          end
        rescue IOError, Errno::EPIPE
        rescue Exception
          print "INTERNAL ERROR!!! #{$!}\n" rescue nil
          print $!.backtrace.map{|l| "\t#{l}"}.join("\n") rescue nil
        ensure
          @interface.close
        end

        def process_command(cmd)
          catch(:debug_error) do
            if matched_cmd = control_commands.find { |c| c.match(cmd) }
              matched_cmd.execute
            else
              process_context_commands(cmd)
            end
          end
        end

        private

          def control_commands
            @control_commands = begin
              control_command_classes = Command.commands.select(&:allow_in_control)
              state = Debugger::ControlCommandProcessor::State.new(@interface, control_command_classes)
              control_command_classes.map { |cmd| cmd.new(state) }
            end
          end

          def process_input(input)
            split_commands(input).each do |cmd|
              process_command(cmd)
            end
          end

          def process_context_commands(input)
            unless Debugger.handler.at_line?
              errmsg pr("base.errors.no_suspended_thread", input: input)
              return
            end
            event_command_classes = Command.commands.select(&:event)
            state = Debugger::CommandProcessor::State.new do |s|
              s.context = Debugger.handler.context
              s.file    = Debugger.handler.file
              s.line    = Debugger.handler.line
              s.binding = Debugger.handler.context.frame_binding(0)
              s.interface = @interface
              s.commands = event_command_classes
            end
            event_commands = event_command_classes.map { |cls| cls.new(state) }
            catch(:debug_error) do
              if cmd = event_commands.find { |c| c.match(input) }
                if state.context.dead? && cmd.class.need_context
                  print pr("base.errors.command_unavailable")
                else
                  cmd.execute
                end
              else
                print pr("base.errors.unknown_command", input: input)
              end
            end
            state.context.thread.run if state.proceed?
          end
      end

    end
  end
end
