module ActiveSupport
  module Testing
    module SetupAndTeardown
      def self.included(base)
        base.send :include, ActiveSupport::Callbacks
        base.define_callbacks :setup, :teardown

        begin
          require 'mocha'
          base.alias_method_chain :run, :callbacks_and_mocha
        rescue LoadError
          base.alias_method_chain :run, :callbacks
        end
      end

      # This redefinition is unfortunate but test/unit shows us no alternative.
      def run_with_callbacks(result) #:nodoc:
        return if @method_name.to_s == "default_test"

        yield(Test::Unit::TestCase::STARTED, name)
        @_result = result
        begin
          run_callbacks :setup
          setup
          __send__(@method_name)
        rescue Test::Unit::AssertionFailedError => e
          add_failure(e.message, e.backtrace)
        rescue *Test::Unit::TestCase::PASSTHROUGH_EXCEPTIONS
          raise
        rescue Exception
          add_error($!)
        ensure
          begin
            teardown
            run_callbacks :teardown, :enumerator => :reverse_each
          rescue Test::Unit::AssertionFailedError => e
            add_failure(e.message, e.backtrace)
          rescue *Test::Unit::TestCase::PASSTHROUGH_EXCEPTIONS
            raise
          rescue Exception
            add_error($!)
          end
        end
        result.add_run
        yield(Test::Unit::TestCase::FINISHED, name)
      end

      # Doubly unfortunate: mocha does the same so we have to hax their hax.
      def run_with_callbacks_and_mocha(result)
        return if @method_name.to_s == "default_test"

        yield(Test::Unit::TestCase::STARTED, name)
        @_result = result
        begin
          mocha_setup
          begin
            run_callbacks :setup
            setup
            __send__(@method_name)
            mocha_verify { add_assertion }
          rescue Mocha::ExpectationError => e
            add_failure(e.message, e.backtrace)
          rescue Test::Unit::AssertionFailedError => e
            add_failure(e.message, e.backtrace)
          rescue StandardError, ScriptError
            add_error($!)
          ensure
            begin
              teardown
              run_callbacks :teardown, :enumerator => :reverse_each
            rescue Test::Unit::AssertionFailedError => e
              add_failure(e.message, e.backtrace)
            rescue StandardError, ScriptError
              add_error($!)
            end
          end
        ensure
          mocha_teardown
        end
        result.add_run
        yield(Test::Unit::TestCase::FINISHED, name)
      end
    end
  end
end
