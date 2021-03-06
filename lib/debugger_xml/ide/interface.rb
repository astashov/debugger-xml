module DebuggerXml
  module Ide
    class Interface
      attr_accessor :command_queue
      attr_accessor :histfile
      attr_accessor :history_save
      attr_accessor :history_length
      attr_accessor :restart_file

      def initialize(socket)
        @command_queue = []
        @socket = socket
        @history_save = false
        @history_length = 256
        @histfile = ''
        @restart_file = nil
      end

      def close
        @socket.close
      rescue Exception
      end

      def print_debug(msg)
        STDOUT.puts(msg)
      end

      def errmsg(*args)
        print(*args)
      end

      def confirm(prompt)
        true
      end

      def finalize
        close
      end

      # Workaround for JRuby issue http://jira.codehaus.org/browse/JRUBY-2063
      def non_blocking_gets
        loop do
          result, _, _ = IO.select([@socket], nil, nil, 0.2)
          next unless result
          return result[0].gets
        end
      end

      def read_command(*args)
        result = non_blocking_gets
        raise IOError unless result
        result.chomp.tap do |r|
          DebuggerXml.logger.puts("Read command: #{r}")
        end
      end

      def readline_support?
        false
      end

      def print(*args)
        escaped_args = escape_input(args)
        value = escaped_args.first % escaped_args[1..-1]
        DebuggerXml.logger.puts("Going to print: #{value}")
        @socket.print(value)
      end

      def puts(*args)
        print(*args)
      end

      private

      def escape_input(args)
        new_args = args.dup
        new_args.first.gsub!("%", "%%") if args.first.is_a?(String)
        new_args
      end

    end
  end
end
