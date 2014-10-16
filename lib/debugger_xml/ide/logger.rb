module DebuggerXml
  module Ide
    class Logger
      def puts(string)
        $stderr.puts(string)
      end
    end
  end
end
