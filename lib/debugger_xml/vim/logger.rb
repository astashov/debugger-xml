module DebuggerXml
  module Vim
    class Logger
      def initialize(logger_file)
        @logger_file = logger_file
      end

      def puts(string)
        File.open(@logger_file, 'a') do |f|
          # match vim redir style new lines, rather than trailing
          f << "\ndebugger-xml, #{Time.now.strftime("%H:%M:%S")} : #{string.chomp}"
        end
      end
    end
  end
end
