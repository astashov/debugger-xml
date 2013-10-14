require 'debugger/xml/ide/interface'

module Debugger
  module Xml
    module Vim
      class Interface < Ide::Interface
        def initialize(socket, options)
          super(socket)
          @options = options
          @output = []
        end

        def print(*args)
          escaped_args = escape_input(args)
          value = escaped_args.first % escaped_args[1..-1]
          Xml.logger.puts("Going to print: #{value}")
          @output << sprintf(value)
        end

        def send_response
          create_directory(@options.file)
          message = @output.join(@options.separator)
          @output.clear
          unless message.empty?
            File.open(@options.file, 'w') do |f|
              f.puts(message)
            end
            Notification.new("receive_command", @options).send
          end
        end

        private

          def create_directory(file)
            dir = File.dirname(file)
            Dir.mkdir(dir) unless File.exist?(dir) && File.directory?(dir)
          end

      end
    end
  end
end
