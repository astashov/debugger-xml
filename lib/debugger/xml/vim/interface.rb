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
          @output << sprintf(*escape_input(args))
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
