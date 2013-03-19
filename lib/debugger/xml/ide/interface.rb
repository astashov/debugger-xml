module Debugger
  module Xml
    module Ide
      class Interface < Debugger::Interface # :nodoc:
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
          result.chomp
        end

        def readline_support?
          false
        end

        def print(*args)
          @socket.printf(*escape_input(args))
        end

      end
    end
  end
end
