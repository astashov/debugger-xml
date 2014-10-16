require 'ruby-debug/processor'

module DebuggerXml
  module Ide
    class Processor
      class << self
        private

        # Copied from debugger gem.
        def protect(mname)
          alias_method "__#{mname}", mname
          module_eval %{
            def #{mname}(*args)
              @mutex.synchronize do
                return unless @interface
                __#{mname}(*args)
              end
            rescue IOError, Errno::EPIPE
              self.interface = nil
            rescue SignalException
              raise
            rescue Exception
              @interface.print "INTERNAL ERROR!!! #\{$!\}\n" rescue nil
              @interface.print $!.backtrace.map{|l| "\t#\{l\}"}.join("\n") rescue nil
            end
          }
        end
      end

      attr_reader :context, :file, :line, :display

      def initialize(interface, proxy)
        @mutex = Mutex.new
        @interface = interface
        @proxy = proxy
        @display = []
      end

      def at_breakpoint(context, breakpoint)
        raise "@last_breakpoint supposed to be nil. is #{@last_breakpoint}" if @last_breakpoint
        # at_breakpoint is immediately followed by #at_line event. So postpone breakpoint printing until #at_line.
        @last_breakpoint = breakpoint
      end
      protect :at_breakpoint

      # TODO: Catching exceptions doesn't work so far, need to fix
      def at_catchpoint(context, excpt)
      end

      # We don't have tracing for IDE
      def at_tracing(*args)
      end

      def at_line(context, file, line)
        if context.nil? || context.stop_reason == :step
          print_file_line(context, file, line)
        end
        line_event(context, file, line)
      end
      protect :at_line

      def at_return(context, file, line)
        print_file_line(context, file, line)
        context.stop_frame = -1
        line_event(context, file, line)
      end

      def at_line?
        !!@line
      end

      private

        def print_file_line(context, file, line)
          @interface.print(
            @proxy.print(
              "stop.suspend",
              file: @proxy.canonic_file(file),
              line_number: line,
              line: @proxy.line_at(file, line),
              thnum: context && context.thnum,
              frames: context && context.stack_size
            )
          )
        end

        def line_event(context, file, line)
          @line = line
          @file = file
          @context = context
          if @last_breakpoint
            # followed after #at_breakpoint in the same thread. Print breakpoint
            # now when @line, @file and @context are correctly set to prevent race
            # condition with `control thread'.
            n = @proxy.breakpoints.index(@last_breakpoint) + 1
            @interface.print(@proxy.print("breakpoints.stop_at_breakpoint",
              id: n, file: @file, line: @line, thread_id: @proxy.current_context.thnum
            ))
          end
          if @proxy.debug_thread?(@context)
            raise @proxy.print("thread.errors.debug_trace", thread: @context.thread)
          end
          # will be resumed by commands like `step', `next', `continue', `finish'
          # from `control thread'
          stop_thread
        ensure
          @line = nil
          @file = nil
          @context = nil
          @last_breakpoint = nil
          @proxy.inspect_command_class.clear_references
        end

        def stop_thread
          Thread.stop
        end
    end
  end
end
