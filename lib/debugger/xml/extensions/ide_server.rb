module Debugger
  class << self
    attr_accessor :wait_for_start

    def start_remote_ide(host, port)
      return if @control_thread
      @mutex = Mutex.new
      @proceed = ConditionVariable.new
      start
      @control_thread = DebugThread.new do
        $stderr.printf "Fast Debugger (debugger-xml #{Xml::VERSION}) listens on #{host}:#{port}\n"
        server = TCPServer.new(host, port)
        while (session = server.accept)
          interface = Xml::Ide::Interface.new(session)
          processor = Xml::Ide::ControlCommandProcessor.new(interface)
          self.handler = Xml::Ide::Processor.new(interface)
          processor.process_commands
        end
      end
      @mutex.synchronize { @proceed.wait(@mutex) } if wait_for_start
    end

    def proceed
      return unless @mutex
      @mutex.synchronize { @proceed.signal }
    end

  end
end
