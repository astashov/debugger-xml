require 'debugger_xml/ide/interface'

module DebuggerXml
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
        DebuggerXml.logger.puts("Going to print: #{value}")
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

        def escape_input(args)
          new_args = args.dup
          new_args.first.gsub!("%", "%%") if args.first.is_a?(String)
          new_args
        end

    end
  end
end
