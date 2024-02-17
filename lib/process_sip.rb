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

  def self.method_missing(name, &)
    Class.new(Adapter, &).new(name).tap do |adapter|
      define_singleton_method(name) do |&block|
        adapter.class.class_eval(&block) if block
        adapter
      end
    end
  end

  class Adapter
    def initialize(name)
      @name = name.dasherize
      @context = Context.new self
    end

    def without(*, &) = with(**@context.without(*), &)
    def with(...)     = clone.tap { _1.instance_variable_set :@context, Context.new(_1, ...) }

    def call(command, *arguments, **options, &block)
      system @name, *@context.arguments, command.to_s, *process_arguments(arguments), *process_options(options)
    end

    ruby2_keywords def method_missing(command, *arguments)
      if arguments.empty?
        Command.new(self, command)
      else
        call(command, *arguments)
      end
    end

    private
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

    def with(...)    = clone.tap { _1.instance_variable_set :@adapter, @adapter.with(...) }
    def without(...) = clone.tap { _1.instance_variable_set :@adapter, @adapter.without(...) }

    def method_missing(name, ...) = call(name.to_s, ...)
    def call(...) = @adapter.call(@name, ...)
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
