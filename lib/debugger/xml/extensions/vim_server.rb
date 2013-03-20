require_relative 'ide_server'

module Debugger
  class << self

    def start_for_vim(options)
      return if @control_thread
      daemonize!
      $stdout.reopen(options.output_file, 'w')
      $stdout.sync
      $stderr.reopen($stdout)
      @mutex = Mutex.new
      @proceed = ConditionVariable.new
      start
      File.unlink(options.socket) if File.exist?(options.socket)
      server = UNIXServer.new(options.socket)
      Xml::Vim::Notification.new("establish_connection", options).send
      @control_thread = DebugThread.new do
        begin
          while (session = server.accept)
            interface = Xml::Vim::Interface.new(session, options)
            processor = Xml::Vim::ControlCommandProcessor.new(interface)
            self.handler = Xml::Vim::Processor.new(interface)
            processor.process_commands
          end
        rescue Exception => e
          puts "INTERNAL ERROR!!! #{$!}" rescue nil
          puts $!.backtrace.map{|l| "\t#{l}"}.join("\n") rescue nil
          raise e
        ensure
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
