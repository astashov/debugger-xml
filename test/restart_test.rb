require_relative 'test_helper'

describe "Restart Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)
  let(:initial_dir) { Pathname.new(__FILE__ + "/../..").realpath.to_s }
  let(:prog_script) do
    Pathname.new(fullpath('restart')).relative_path_from(Pathname.new(Debugger::INITIAL_DIR)).cleanpath.to_s
  end
  let(:rdebug_script) { 'rdebug-script' }

  describe "messaging" do
    before do
      enter 'restart'
      force_set_const(Debugger, "INITIAL_DIR", initial_dir)
      force_set_const(Debugger, "PROG_SCRIPT", prog_script)
      force_set_const(Debugger, "RDEBUG_SCRIPT", rdebug_script)
      Debugger::Command.settings[:argv] = ['argv']
      Debugger::RestartCommand.any_instance.stubs(:exec).with("#{rdebug_script} argv")
    end

    describe "reexecing" do
      it "must show a message about reexecing" do
        debug_file('restart')
        check_output_includes "<restart command=\"#{rdebug_script} argv\"/>"
      end
    end

    describe "no script is specified and don't use $0" do
      before do
        Debugger.send(:remove_const, "PROG_SCRIPT")
        force_set_const(Debugger, "DEFAULT_START_SETTINGS", init: false, post_mortem: false, tracing: nil)
      end

      it "must show an error message" do
        debug_file('restart')
        check_output_includes "<error>Don't know name of debugged program</error>", interface.error_queue
      end
    end

    describe "no script at the specified path" do
      before { force_set_const(Debugger, "PROG_SCRIPT", 'blabla') }

      it "must show an error message" do
        debug_file('restart')
        check_output_includes "<error>Ruby program blabla doesn't exist</error>", interface.error_queue
      end
    end
  end
end
