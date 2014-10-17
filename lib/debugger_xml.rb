Dir.glob(File.expand_path("../debugger_xml/**/*.rb", __FILE__)).each { |f| require f }
if DEBUGGER_TYPE == :debugger
  Dir.glob(File.expand_path("../debugger/**/*.rb", __FILE__)).each { |f| require f }
else
  Dir.glob(File.expand_path("../byebug/**/*.rb", __FILE__)).each { |f| require f }
end

module DebuggerXml
  class << self
    attr_accessor :logger, :wait_for_start, :control_thread, :handler

    def start_remote_ide(proxy, host, port)
      return if @control_thread
      @mutex = Mutex.new
      @proceed = ConditionVariable.new
      proxy.start
      @control_thread = proxy.debug_thread_class.new do
        server = TCPServer.new(host, port)
        $stderr.printf "Fast Debugger (debugger-xml #{VERSION}) listens on #{host}:#{port}\n"
        while (session = server.accept)
          dispatcher = ENV['IDE_PROCESS_DISPATCHER']
          if dispatcher && !dispatcher.include?(":")
            ENV['IDE_PROCESS_DISPATCHER'] = "#{session.peeraddr[2]}:#{dispatcher}"
          end
          interface = DebuggerXml::Ide::Interface.new(session)
          debugger_class.handler = DebuggerXml::Ide::Processor.new(interface, proxy)
          processor = DebuggerXml::Ide::ControlCommandProcessor.new(interface, proxy)
          processor.process_commands
        end
      end
      @mutex.synchronize { @proceed.wait(@mutex) } if wait_for_start
    end

    def start_for_vim(proxy, options)
      return if @control_thread
      logger.puts("Going to daemonize")
      daemonize!
      logger.puts("Successfully daemonized")
      $stdout.reopen(options.output_file, 'w')
      $stdout.sync
      $stderr.reopen($stdout)
      logger.puts("Redirected stderr")
      @mutex = Mutex.new
      @proceed = ConditionVariable.new
      proxy.start
      logger.puts("Started debugger")
      File.unlink(options.socket) if File.exist?(options.socket)
      server = UNIXServer.new(options.socket)
      Vim::Notification.new("establish_connection", options).send
      logger.puts("Sent 'established_connection' command")
      @control_thread = proxy.debug_thread_class.new do
        begin
          while (session = server.accept)
            logger.puts("Accepted connection");
            interface = Vim::Interface.new(session, options)
            proxy.handler = Vim::Processor.new(interface, proxy)
            processor = Vim::ControlCommandProcessor.new(interface, proxy)
            logger.puts("Going to process commands");
            processor.process_commands
          end
        rescue Exception => e
          logger.puts("INTERNAL ERROR!!! #{$!}") rescue nil
          logger.puts($!.backtrace.map { |l| "\t#{l}" }.join("\n")) rescue nil
          raise e
        ensure
          logger.puts("Closing server");
          server.close
        end
      end
      @mutex.synchronize { @proceed.wait(@mutex) } if wait_for_start
    end

    def proceed
      return unless @mutex
      @mutex.synchronize { @proceed.signal }
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
