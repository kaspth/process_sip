# frozen_string_literal: true

require "shellwords"
require_relative "process_sip/version"

module ProcessSip
  require_relative "process_sip/refinements"
  using Refinements

  # ProcessSip.load_each :git, :curl
  def self.load_each(*names)
    names.each do
      require "lib/process_sip/adapters/#{_1}"
    end
  end

  @adapters = {}

  def self.method_missing(name)
    (@adapters[name] ||= Adapter).new(name)
  end

  def self.adapter(adapter, &)
    @adapters[adapter] ||= Class.new(Adapter, &)
  end

  class Adapter
    def initialize(name)
      @name = name.dasherize
      @context = Context.new self
    end

    def with(...)     = new_with_context(...)
    def without(*, &) = new_with_context(**@context.without(*), &)

    def exec(command, *arguments, **options, &block)
      system @name, *@context.arguments, command.to_s, *process_arguments(arguments), *process_options(options)
    end

    ruby2_keywords def method_missing(command, *arguments)
      if arguments.empty?
        Command.new(self, command)
      else
        exec(command, *arguments)
      end
    end

    private
      protected attr_accessor :context

      def new_with_context(...) = clone.tap { _1.context = Context.new(_1, ...) }

      def process_arguments(arguments)
        arguments.map { _1.is_a?(Symbol) ? "-#{_1}" : _1 }.map(&:dasherize)
      end

      def process_options(options)
        options.flat_map { [ "-#{_1.dasherize}", _2 ] }
      end
  end

  class Command
    def initialize(adapter, name)
      @adapter, @name = adapter, name.dasherize
    end

    def with(...)    = clone.tap { _1.adapter = adapter.with(...) }
    def without(...) = clone.tap { _1.adapter = adapter.without(...) }

    def exec(...) = adapter.exec(@name, ...)

    def method_missing(name, ...) = exec(name.to_s, ...)

    protected attr_accessor :adapter
  end

  class Context
    attr_reader :arguments

    def initialize(adapter, *keys, **options)
      @adapter, @options = adapter, keys.index_with(nil).merge(options)
      @arguments = @options.map { [ "--#{_1.dasherize}", _2&.shellescape ].compact.join("=") }
    end

    def without(*keys)
      keys.none? ? {} : @options.except(*keys)
    end
  end
end
