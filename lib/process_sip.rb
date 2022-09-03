# frozen_string_literal: true

require "shellwords"
require_relative "process_sip/version"

module ProcessSip
  require_relative "process_sip/extensions"
  using Extensions

  def self.method_missing(command)
    Executable.new(command)
  end

  class Executable
    def initialize(name)
      @name = name.dasherize
      @context = Context.new self
    end

    def with(*keys, **options, &block)
      new_with_context(*keys, **options, &block)
    end

    def without(*keys, &block)
      new_with_context(**@context.without(*keys), &block)
    end

    def exec(command, *arguments, **options, &block)
      system @name, *@context.arguments, command.to_s, *process_arguments(arguments), *process_options(options)
    end

    def method_missing(command, *arguments, **options)
      if arguments.empty? && options.empty?
        Command.new(self, command)
      else
        exec(command, *arguments, **options)
      end
    end

    private
      protected attr_accessor :context

      def new_with_context(*keys, **options)
        clone.tap { _1.context = Context.new(_1, *keys, **options) }
      end

      def process_arguments(arguments)
        arguments.map { _1.is_a?(Symbol) ? "-#{_1}" : _1 }.map(&:dasherize)
      end

      def process_options(options)
        options.flat_map { [ "-#{_1.dasherize}", _2 ] }
      end
  end

  class Command
    def initialize(executable, name)
      @executable, @name = executable, name.dasherize
    end

    def with(...)
      clone.tap { _1.executable = executable.with(...) }
    end

    def without(...)
      clone.tap { _1.executable = executable.without(...) }
    end

    def exec(...)
      executable.exec(@name, ...)
    end

    def method_missing(name, ...)
      exec(name.to_s, ...)
    end

    protected attr_accessor :executable
  end

  class Context
    attr_reader :arguments

    def initialize(executable, *keys, **options)
      @executable, @options = executable, keys.index_with(nil).merge(options)
      @arguments = @options.map { [ "--#{_1.dasherize}", _2&.shellescape ].compact.join("=") }
    end

    def without(*keys)
      keys.none? ? {} : @options.except(*keys)
    end
  end
end
