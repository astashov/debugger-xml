module DebuggerXml
  module Vim
    class Notification

      def initialize(command, options)
        @command = command
        @executable = options.vim_executable
        @servername = options.vim_servername
        @debug_mode = options.debug_mode
        @logger_file = options.logger_file
      end

      def send
        command = ":call RubyDebugger.#{@command}()"
        starter = "<C-\\\\>"
        sys_cmd = "#{@executable} --servername #{@servername} -u NONE -U NONE " +
          "--remote-send \"#{starter}<C-N>#{command}<CR>\""
        log("Executing command: #{sys_cmd}")
        system(sys_cmd);
      end

      private

        def log(string)
          if @debug_mode
            File.open(@logger_file, 'a') do |f|
              # match vim redir style new lines, rather than trailing
              f << "\ndebugger-xml, #{Time.now.strftime("%H:%M:%S")} : #{string.chomp}"
            end
          end
        end

    end
  end
end
