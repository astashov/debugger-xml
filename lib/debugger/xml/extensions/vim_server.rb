require_relative 'ide_server'

module Debugger
  class << self

    def start_for_vim(options)
      return if @control_thread
      Xml.logger.puts("Going to daemonize");
      daemonize!
      Xml.logger.puts("Successfully daemonized");
      $stdout.reopen(options.output_file, 'w')
      $stdout.sync
      $stderr.reopen($stdout)
      Xml.logger.puts("Redirected stderr");
      @mutex = Mutex.new
      @proceed = ConditionVariable.new
      start
      Xml.logger.puts("Started debugger");
      File.unlink(options.socket) if File.exist?(options.socket)
      server = UNIXServer.new(options.socket)
      Xml::Vim::Notification.new("establish_connection", options).send
      Xml.logger.puts("Sent 'established_connection' command");
      @control_thread = DebugThread.new do
        begin
          while (session = server.accept)
            Xml.logger.puts("Accepted connection");
            interface = Xml::Vim::Interface.new(session, options)
            processor = Xml::Vim::ControlCommandProcessor.new(interface)
            self.handler = Xml::Vim::Processor.new(interface)
            Xml.logger.puts("Going to process commands");
            processor.process_commands
          end
        rescue Exception => e
          Xml.logger.puts("INTERNAL ERROR!!! #{$!}") rescue nil
          Xml.logger.puts($!.backtrace.map{|l| "\t#{l}"}.join("\n")) rescue nil
          raise e
        ensure
          Xml.logger.puts("Closing server");
          server.close
        end
      end
      @mutex.synchronize { @proceed.wait(@mutex) } if wait_for_start
    end

    private

      def daemonize!
        pid = Process.fork
        if pid
          print pid
          exit
        end
      end

  end
end
