module DebuggerXml
  module MultiProcess
    class << self
      def pre_child
        return unless ENV['IDE_PROCESS_DISPATCHER']

        require 'socket'
        require 'ostruct'

        host = ENV['DEBUGGER_HOST']
        port = find_free_port(host)

        options = OpenStruct.new(
          host: host,
          port: port,
          stop: false,
          tracing: false,
          wait_for_start: true,
          int_handler: true,
          debug_mode: (ENV['DEBUGGER_DEBUG_MODE'] == 'true'),
          dispatcher_port: ENV['IDE_PROCESS_DISPATCHER']
        )

        acceptor_host, acceptor_port = ENV['IDE_PROCESS_DISPATCHER'].split(":")
        acceptor_host, acceptor_port = '127.0.0.1', acceptor_host unless acceptor_port

        connected = false
        3.times do |i|
          begin
            s = TCPSocket.open(acceptor_host, acceptor_port)
            s.print(port)
            s.close
            connected = true
            start_debugger(options)
            return
          rescue => bt
            $stderr.puts "#{Process.pid}: connection failed(#{i+1})"
            $stderr.puts "Exception: #{bt}"
            $stderr.puts bt.backtrace.map { |l| "\t#{l}" }.join("\n")
            sleep 0.3
          end unless connected
        end
      end

      def start_debugger(options)
        if Debugger.started?
          # we're in forked child, only need to restart control thread
          Debugger.breakpoints.clear
          Debugger.control_thread = nil
        end

        if options.int_handler
          # install interruption handler
          trap('INT') { Debugger.interrupt_last }
        end

        # set options
        Debugger.tracing = options.tracing
        Debugger.wait_for_start = options.wait_for_start
        Debugger.wait_connection = true
        Debugger.printer = Printers::Xml.new
        DebuggerXml.logger = if options.debug_mode
          Debugger::Xml::Ide::Logger.new
        else
          Debugger::Xml::FakeLogger.new
        end
        DebuggerXml.start_remote_ide(options.host, options.port)
      end


      def find_free_port(host)
        server = TCPServer.open(host, 0)
        port   = server.addr[1]
        server.close
        port
      end
    end
  end
end
