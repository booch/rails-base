# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

include AuthenticatedTestHelper

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end


# TODO: Perhaps merge be_valid() with be_valid_with().
#         Maybe use syntax like be_valid(:with => :attrib, :set_to_any_of => [nil, 0, 1.0, 0.01])
#         Maybe add be_valid(:with => :attrib, :in => 0..1000) which would test endpoints, several internal values.
#         And the counterpart be_valid(:with => :attrib, :outside => 0..1000)
module Spec
  module Rails
    module Matchers
      # Got this one from http://opensoul.org/2007/4/18/rspec-model-should-be_valid
      class BeValid  #:nodoc:
        def matches?(model)
          @model = model
          @model.valid?
        end
        def failure_message
          "#{@model.class} expected to be valid but had errors:\n  #{@model.errors.full_messages.join("\n  ")}"
        end
        def negative_failure_message
          "#{@model.class} expected to be invalid but was valid.\n"
        end
        def description
          'be valid'
        end
      end
      def be_valid
        BeValid.new
      end

      # I believe I wrote this one myself. (Craig Buchek)
      class BeA  #:nodoc:
        def initialize(klass)
          @klass = klass
        end
        def matches?(obj)
          @obj = obj
          @obj.is_a? @klass
        end
        def failure_message
          "object expected to be a(n) #{@klass.name} but was a(n) #{@obj.class.name}\n"
        end
        def negative_failure_message
          "object expected to NOT be a(n) #{@klass.name} but was a(n) #{@klass.name} (#{@obj.class.name})\n"
        end
        def description
          'be an instance of (a subclass of) the given class'
        end
      end
      def be_a(klass)
        BeA.new(klass)
      end
      def be_an(klass)
        BeA.new(klass)
      end

      # I wrote this one myself, to combine be_a and be_valid. (Craig Buchek)
      class BeAValid  #:nodoc:
        def initialize(klass)
          @klass = klass
        end
        def matches?(obj)
          @obj = obj
          @is_a = @obj.is_a?(@klass)
          @is_valid = @obj.valid?
          return (@is_a and @is_valid)
        end
        def failure_message
          message = ''
          message += "object expected to be a(n) #{@klass.name} but was a(n) #{@obj.class.name}\n" if !@is_a
          message += "#{@obj.class} expected to be valid but had errors:\n  #{@obj.errors.full_messages.join("\n  ")}" if !@is_valid
        end
        def negative_failure_message
          message = ''
          message += "object expected to NOT be a(n) #{@klass.name} but was a(n) #{@klass.name} (#{@obj.class.name})\n" if !@is_a
          message += "#{@obj.class} expected to be invalid but was valid.\n" if !@is_valid
        end
        def description
          'be a valid ActiveRecord object'
        end
      end
      def be_a_valid(klass)
        BeAValid.new(klass)
      end

      # I wrote these to make it easy to specify invalid and valid attributes in a list, to "declare" good and bad attribute values to test. (CMB)
      # Example: @quote_section.should be_valid_with(:name, ['Craig', 'Bob', 'a' * 64, 'John Johnson'])
      # Example: @quote_section.should be_invalid_with(:name, [nil, '', 'a' * 65, 12.2])
      # TODO: Can I replace should be_invalid_with() with should_not be_valid_with()? I don't think so.
      class BeValidWith  #:nodoc:
        def initialize(attrib, array_of_values)
          @attrib = attrib
          array_of_values = [array_of_values] if !array_of_values.respond_to?(:[]) # Allow a single value in place of an array.
          @array_of_values = array_of_values
        end
        def matches?(model)
          @model = model
          attrib_set = (@attrib.to_s + '=').to_sym
          @array_of_values.each do |value|
            @model.send(attrib_set, value)
            if !@model.valid?
              @invalid_value = value
              return false
            end
          end
          return true
        end
        def failure_message
          "#{@model.class} expected to be valid when #{@attrib}=#{@invalid_value.inspect} but had errors:\n  #{@model.errors.full_messages.join("\n  ")}"
        end
        def description
          'be valid with given attribute set to each/any of the given values'
        end
      end
      class BeInvalidWith  #:nodoc:
        def initialize(attrib, array_of_values)
          @attrib = attrib
          array_of_values = [array_of_values] if !array_of_values.respond_to?(:[]) # Allow a single value in place of an array.
          @array_of_values = array_of_values
        end
        def matches?(model)
          @model = model
          attrib_set = (@attrib.to_s + '=').to_sym
          @array_of_values.each do |value|
            @model.send(attrib_set, value)
            if @model.valid?
              @valid_value = value
              return false
            end
          end
          return true
        end
        def failure_message
          "#{@model.class} expected to be invalid when #{@attrib}=#{@valid_value.inspect} but had no errors\n"
        end
        def description
          'be invalid with given attribute set to each/any of the given values'
        end
      end
      def be_valid_with(attrib, array_of_values)
        BeValidWith.new(attrib, array_of_values)
      end
      def be_invalid_with(attrib, array_of_values)
        BeInvalidWith.new(attrib, array_of_values)
      end

      # I wrote this one myself, to have an inverse of should include. (Craig Buchek)
      class BeIn  #:nodoc:
        def initialize(object)
          @object = object
        end
        def matches?(container)
          @container = container
          @container.include?(@object)
        end
        def failure_message
          "#{@object} was expected to be in #{@container}, but was not.\n"
        end
        def negative_failure_message
          "#{@object} was NOT expected to be in #{@container}, but was.\n"
        end
        def description
          'be a member of (included in) the given collection'
        end
      end
      def be_in
        BeIn.new
      end

      # Got this one from http://www.elevatedrails.com/articles/2007/05/09/custom-expectation-matchers-in-rspec/
      class HaveErrorOn
        def initialize(field)
          @field=field
        end
        def matches?(model)
          @model=model
          @model.valid?
          !@model.errors.on(@field).nil?
        end
        def description
          "have error(s) on #{@field}"
        end
        def failure_message
          "expected to have error(s) on #{@field} but doesn't"
        end
        def negative_failure_message
          "expected NOT to have errors on #{@field} but does have an error: #{@model.errors.on(@field)}"
        end
      end
      def have_error_on(field)
        HaveErrorOn.new(field)
      end
      def have_errors_on(field)
        HaveErrorOn.new(field)
      end

    end
  end
end
