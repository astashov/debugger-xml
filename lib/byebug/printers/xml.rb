require 'byebug/printers/base'
require 'builder'

module Byebug
  module Printers
    class Xml < Byebug::Printers::Base

      def print(path, args = {})
        case parts(path)[1]
        when "errors"
          print_error(path, args)
        when "confirmations"
          print_confirmation(path, args)
        when "debug"
          print_debug(path, args)
        when "messages"
          print_message(path, args)
        else
          print_general(path, args)
        end
      end

      def print_collection(path, collection, &block)
        settings = locate(path)
        xml = ::Builder::XmlMarkup.new
        tag = translate(settings["tag"])
        xml.tag!("#{tag}s") do |xml|
          array_of_args(collection, &block).each do |args|
            xml.tag!(tag, translated_attributes(settings["attributes"], args))
          end
        end
      end

      def print_variables(variables, global_kind)
        print_collection("variable.variable", variables) do |(key, value, kind), index|
          Variable.new(key, value, kind || global_kind).to_hash
        end
      end

      def print_instance_variables(object)
        variables = if object.is_a?(Array)
          object.each.with_index.map { |item, index| ["[#{index}]", item, 'instance'] }
        elsif object.is_a?(Hash)
          object.map { |key, value| [key.is_a?(String) ? "'#{key}'" : key.to_s, value, 'instance'] }
        else
          AllVariables.new(object).variables
        end
        print_variables(variables, nil)
      end

      private

        def print_general(path, args)
          settings = locate(path)
          xml = ::Builder::XmlMarkup.new
          tag = translate(settings["tag"], args)
          attributes = translated_attributes(settings["attributes"], args)
          xml.tag!(tag, attributes)
        end

        def print_debug(path, args)
          translate(locate(path), args)
        end

        def print_error(path, args)
          xml = ::Builder::XmlMarkup.new
          xml.error { print_content(xml, path, args) }
        end

        def print_confirmation(path, args)
          xml = ::Builder::XmlMarkup.new
          xml.confirmation { print_content(xml, path, args) }
        end

        def print_message(path, args)
          xml = ::Builder::XmlMarkup.new
          xml.message { print_content(xml, path, args) }
        end

        def print_content(xml, path, args)
          xml.text!(translate(locate(path), args))
        end

        def translated_attributes(attributes, args)
          attributes.inject({}) do |hash, (key, value)|
            hash[key] = translate(value, args)
            hash
          end
        end

        def contents_files
          [File.expand_path(File.join("..", "texts", "xml.yml"), __FILE__)] + super
        end

      class Variable
        attr_reader :name, :kind
        def initialize(name, value, kind = nil)
          @name = name.to_s
          @value = value
          @kind = kind
        end

        def has_children?
          if @value.is_a?(Array) || @value.is_a?(Hash)
            !@value.empty?
          else
            !@value.instance_variables.empty? || !@value.class.class_variables.empty?
          end
        rescue
          false
        end

        def value
          if @value.is_a?(Array) || @value.is_a?(Hash)
            if has_children?
              "#{@value.class} (#{@value.size} element(s))"
            else
              "Empty #{@value.class}"
            end
          else
            value_str = @value.nil? ? 'nil' : @value.to_s
            if !value_str.is_a?(String)
              "ERROR: #{@value.class}.to_s method returns #{value_str.class}. Should return String."
            elsif binary_data?(value_str)
              "[Binary Data]"
            else
              value_str.gsub(/^(")(.*)(")$/, '\2')
            end
          end
        rescue => e
          "<raised exception: #{e}>"
        end

        def id
          @value.respond_to?(:object_id) ? "%#+x" % @value.object_id : nil
        rescue
          nil
        end

        def type
          @value.class
        rescue
          "Undefined"
        end

        def to_hash
          {name: @name, kind: @kind, value: value, type: type, has_children: has_children?, id: id}
        end

        private

          def binary_data?(string)
            string.count("\x00-\x7F", "^ -~\t\r\n").fdiv(string.size) > 0.3 || string.index("\x00") unless string.empty?
          end
      end

      class AllVariables
        def initialize(object)
          @object = object
          @instance_binding = object.instance_eval{binding()}
          @class_binding = object.class.class_eval('binding()')

          @instance_variable_names = object.instance_variables
          @self_variable_name = @instance_variable_names.delete('self')
          @class_variable_names = object.class.class_variables
        end

        def variables
          self_variables + instance_variables + class_variables
        end

        private

          def instance_variables
            @instance_variable_names.map do |var|
              [var.to_s, (eval(var.to_s, @instance_binding) rescue "<raised exception>"), 'instance']
            end
          end

          def self_variables
            if @self_variable_name
              [@self_variable_name, (eval(@self_variable_name, @instance_binding)), 'instance']
            else
              []
            end
          end

          def class_variables
            @class_variable_names.map do |var|
              [var.to_s, (eval(var.to_s, @class_binding) rescue "<raised exception>"), 'class']
            end
          end
      end

    end
  end
end
