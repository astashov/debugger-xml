require_relative '../test_helper'
require 'ostruct'

describe "Printers::Xml" do
  include PrinterHelpers

  let(:klass) { Printers::Xml }
  let(:printer) { klass.new }
  let(:yaml_xml) do
    {
      "foo" => {
        "errors" => {
          "bad" => "bad behavior"
        },
        "confirmations" => {
          "okay" => "Okay?"
        },
        "debug" => {
          "dbg" => "Debug message"
        },
        "bar" => {
          "tag" => "xmltag",
          "attributes" => {
            "boo" => "{zee} > {uga}",
            "agu" => "bew"
          }
        }
      },
      "variable" => {
        "variable" => {
          "tag" => "variable",
          "attributes" => {
            "name" => "{name}",
            "kind" => "{kind}",
            "value" => "{value}",
            "type" => "{type}",
            "hasChildren" => "{has_children}",
            "objectId" => "{id}"
          }
        }
      }
    }
  end

  def yaml_file_path(filename)
    File.expand_path(
      File.join("..", "..", "..", "lib", "debugger", "printers", "texts", "#{filename}.yml"),
      __FILE__
    )
  end

  before do
    YAML.stubs(:load_file).with(yaml_file_path('xml')).returns(yaml_xml)
    YAML.stubs(:load_file).with(regexp_matches(/base/)).returns({})
  end

  describe "#print" do
    it "must return correctly translated string" do
      xml = ::Builder::XmlMarkup.new.xmltag(boo: "zuu > aga", agu: "bew")
      printer.print("foo.bar", zee: "zuu", uga: "aga").must_equal xml
    end

    it "must return error string" do
      printer.print("foo.errors.bad").must_equal "<error>bad behavior</error>"
    end

    it "must return confirmation string" do
      printer.print("foo.confirmations.okay").must_equal "<confirmation>Okay?</confirmation>"
    end

    it "must return debug string" do
      printer.print("foo.debug.dbg").must_equal "Debug message"
    end
  end

  describe "#print_collection" do
    it "must print collection" do
      expected = ::Builder::XmlMarkup.new.xmltags do |x|
        x.xmltag(boo: "0 > a", agu: "bew") + x.xmltag(boo: "1 > b", agu: "bew")
      end
      result = printer.print_collection("foo.bar", [{uga: 'a'}, {uga: 'b'}]) do |item, index|
        item.merge(zee: index)
      end
      result.must_equal expected
    end
  end

  describe "#print_variables" do
    it "must print variables" do
      vars = [["a", "b"], ["c", "d"]]
      expected = ::Builder::XmlMarkup.new.variables do |x|
        vars.map do |key, value|
          x.variable(name: key, kind: "instance", value: value, type: "String", hasChildren: "false", objectId: "%#+x" % value.object_id)
        end.join("")
      end
      result = printer.print_variables(vars, 'instance')
      result.must_equal expected
    end
  end

  describe "Printers::Xml::Variable" do
    let(:klass) { Printers::Xml::Variable }

    describe "#has_children?" do
      describe "value is Array" do
        it("must be true for non-empty") { klass.new('bla', ['a']).has_children?.must_equal(true) }
        it("must be false for empty") { klass.new('bla', []).has_children?.must_equal(false) }
      end

      describe "value is Hash" do
        it("must be true for non-empty") { klass.new('bla', {a: 'b'}).has_children?.must_equal(true) }
        it("must be false for empty") { klass.new('bla', {}).has_children?.must_equal(false) }
      end

      describe "value is some random class" do
        unless const_defined?("VariableExampleWithInstanceVars")
          class VariableExampleWithInstanceVars; def initialize; @a = '1'; end; end
        end
        unless const_defined?("VariableExampleWithClassVars")
          class VariableExampleWithClassVars; def initialize; @@a = '1'; end; end
        end
        unless const_defined?("VariableExampleWithoutVars")
          class VariableExampleWithoutVars; end
        end
        it("must be true if has instance variables") { klass.new('bla', VariableExampleWithInstanceVars.new).has_children?.must_equal(true) }
        it("must be true if has class variables") { klass.new('bla', VariableExampleWithClassVars.new).has_children?.must_equal(true) }
        it("must be false if has no any variables") { klass.new('bla', VariableExampleWithoutVars.new).has_children?.must_equal(false) }
        it("must be false as a fallback") { klass.new('bla', BasicObject.new).has_children?.must_equal(false) }
      end
    end

    describe "#value" do
      describe "value is a Array" do
        it("must return string for empty") { klass.new('bla', []).value.must_equal("Empty Array") }
        it("must return result for non-empty") { klass.new('bla', [1, 2]).value.must_equal("Array (2 element(s))") }
      end

      describe "value is a Hash" do
        it("must return string for empty") { klass.new('bla', {}).value.must_equal("Empty Hash") }
        it("must return result for non-empty") { klass.new('bla', {a: 'b', c: 'd'}).value.must_equal("Hash (2 element(s))") }
      end

      describe "value is some random class" do
        unless const_defined?("ToSReturnNotAString")
          class ToSReturnNotAString; def to_s; {}; end; end
        end
        it("must return nil for nil") { klass.new('bla', nil).value.must_equal("nil") }
        it("must return #to_s for any other class") do
          klass.new('bla', OpenStruct.new(a: 'b')).value.must_equal '#<OpenStruct a="b">'
        end
        it("must be able to show error") do
          klass.new('bla', BasicObject.new).value.must_match /<raised exception: undefined method/
        end
        it("must get rid of quotes") { klass.new('bla', '"foo"').value.must_equal 'foo' }
        it("must return special message for binary") { klass.new('bla', "\xFF\x12").value.must_equal '[Binary Data]' }
        it("must show error if returned value is not a string") do
          klass.new('bla', ToSReturnNotAString.new).value.must_equal(
            'ERROR: ToSReturnNotAString.to_s method returns Hash. Should return String.'
          )
        end
      end
    end

    describe "#id" do
      it "must show object_id" do
        object = Object.new
        klass.new('bla', object).id.must_equal("%#+x" % object.object_id)
      end

      it "must return nil as a fallback" do
        klass.new('bla', BasicObject.new).id.must_be_nil
      end
    end

    describe "#type" do
      it "must return class" do
        klass.new('bla', Object.new).type.must_equal(Object.new.class)
      end

      it "must return 'Undefined' as a callback" do
        klass.new('bla', BasicObject.new).type.must_equal "Undefined"
      end
    end

    describe "#name" do
      it "must return name as a string" do
        klass.new(:bla, "value").name.must_equal "bla"
      end
    end

    describe "#to_hash" do
      it "must return a hash with values" do
        var = "foo"
        klass.new(:bla, var).to_hash.must_equal(
          {name: "bla", kind: nil, value: var, type: String, has_children: false, id: "%#+x" % var.object_id}
        )
      end
    end

  end
end
