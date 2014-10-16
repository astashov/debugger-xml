require_relative 'test_helper'

describe "Breakpoints" do
  include TestDsl

  describe "setting breakpoint in the current file" do
    it "must return right response" do
      enter 'break 10'
      id = nil
      debug_file('breakpoint1') { id = breakpoint.id }
      check_output_includes "<breakpointAdded no=\"#{id}\" location=\"#{fullpath('breakpoint1')}:10\"/>"
    end
  end

  describe "setting breakpoint to unexisted line" do
    it "must show an error" do
      enter 'break 100'
      debug_file("breakpoint1")
      check_output_includes "<error>There are only 15 lines in file 'breakpoint1.rb'</error>", interface.error_queue
    end
  end


  describe "shows a message when stopping at breakpoint" do
    temporary_change_hash_value(Debugger::Command.settings, :basename, false)

    it "must show a message with full filename" do
      enter 'break 14', 'cont'
      debug_file("breakpoint1")
      check_output_includes "<breakpoint file=\"#{fullpath('breakpoint1')}\" line=\"14\" threadId=\"1\"/>"
    end

    it "must show a message with basename" do
      enter 'set basename', 'break 14', 'cont'
      debug_file("breakpoint1")
      check_output_includes "<breakpoint file=\"breakpoint1.rb\" line=\"14\" threadId=\"1\"/>"
    end

    it "must not show <suspended>" do
      enter 'break 14', 'cont'
      debug_file("breakpoint1")
      check_output_doesnt_include /<suspended[^>]+line="14"/
    end
  end

  describe "set breakpoint in a file when setting breakpoint to unexisted file" do
    before do
      enter "break asf:324"
      debug_file("breakpoint1")
    end

    it "must show an error" do
      check_output_includes "<error>No source file named asf</error>", interface.error_queue
    end

    it "must ask about setting breakpoint anyway" do
      check_output_includes "<confirmation>Set breakpoint anyway?</confirmation>", interface.confirm_queue
    end
  end

  describe "set breakpoint to a method" do
    describe "set breakpoint to an instance method" do
      it "must output show in xml" do
        enter 'break A#b', 'cont'
        id = nil
        debug_file("breakpoint1") { id = breakpoint.id }
        check_output_includes "<breakpointAdded no=\"#{id}\" method=\"A::b\"/>"
      end
    end

    describe "set breakpoint to unexisted class" do
      it "must show an error" do
        enter "break B.a"
        debug_file("breakpoint1")
        check_output_includes "<error>Unknown class B</error>", interface.error_queue
      end
    end
  end

  describe "set breakpoint to an invalid location" do
    it "must show an error" do
      enter "break foo"
      debug_file("breakpoint1")
      check_output_includes '<error>Invalid breakpoint location: foo</error>', interface.error_queue
    end
  end


  describe "disabling a breakpoint" do
    it "must show success message" do
      enter "break 14", ->{"disable #{breakpoint.id}"}, "break 15"
      id = nil
      debug_file("breakpoint1") { id = breakpoint.id }
      check_output_includes "<breakpointDisabled bp_id=\"#{id}\"/>"
    end

    describe "errors" do
      it "must show an error if syntax is incorrect" do
        enter "disable"
        debug_file("breakpoint1")
        check_output_includes(
          "<error>'disable' must be followed 'display', 'breakpoints' or breakpoint numbers</error>",
          interface.error_queue
        )
      end

      it "must show an error if no breakpoints is set" do
        enter "disable 1"
        debug_file("breakpoint1")
        check_output_includes '<error>No breakpoints have been set</error>', interface.error_queue
      end

      it "must show an error if not a number is provided as an argument to 'disable' command" do
        enter "break 14", "disable foo"
        debug_file("breakpoint1")
        check_output_includes "<error>Disable breakpoints argument 'foo' needs to be a number</error>"
      end
    end
  end

  describe "enabling a breakpoint" do
    it "must show success message" do
      enter "break 14", ->{"enable #{breakpoint.id}"}, "break 15"
      id = nil
      debug_file("breakpoint1") { id = breakpoint.id }
      check_output_includes "<breakpointEnabled bp_id=\"#{id}\"/>"
    end

    it "must show an error if syntax is incorrect" do
      enter "enable"
      debug_file("breakpoint1")
      check_output_includes(
        "<error>'enable' must be followed 'display', 'breakpoints' or breakpoint numbers</error>",
        interface.error_queue
      )
    end
  end

  describe "deleting a breakpoint" do
    it "must show a success message" do
      breakpoint_id = nil
      enter "break 14", ->{breakpoint_id = breakpoint.id; "delete #{breakpoint_id}"}, "break 15"
      debug_file("breakpoint1")
      check_output_includes "<breakpointDeleted no=\"#{breakpoint_id}\"/>"
    end
  end

  describe "Conditional breakpoints" do
    it "must show an error when conditional syntax is wrong" do
      enter "break 14 ifa b == 3", "break 15", "cont"
      debug_file("breakpoint1") { state.line.must_equal 15 }
      check_output_includes(
        "<error>Expecting 'if' in breakpoint condition; got: ifa b == 3</error>",
        interface.error_queue
      )
    end

    describe "enabling with wrong conditional syntax" do
      it "must show an error" do
        enter(
          "break 14",
          ->{"disable #{breakpoint.id}"},
          ->{"cond #{breakpoint.id} b -=( 3"},
          ->{"enable #{breakpoint.id}"}
        )
        debug_file("breakpoint1")
        check_output_includes(
          "<error>Expression 'b -=( 3' syntactically incorrect; breakpoint remains disabled</error>",
          interface.error_queue
        )
      end
    end

    it "must show an error if no file or line is specified" do
      enter "break ifa b == 3", "break 15", "cont"
      debug_file("breakpoint1") { state.line.must_equal 15 }
      check_output_includes "<error>Invalid breakpoint location: ifa b == 3</error>", interface.error_queue
    end

    it "must show an error if expression syntax is invalid" do
      enter "break if b -=) 3", "break 15", "cont"
      debug_file("breakpoint1") { state.line.must_equal 15 }
      check_output_includes(
        "<error>Expression 'b -=) 3' syntactically incorrect; breakpoint disabled</error>",
        interface.error_queue
      )
    end
  end
end
