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
      @name, @context = name.dasherize, Context.new
    end

    def omit(*keys)     = clone.tap { _1.instance_variable_set :@context, @context.except(*keys) }
    def with(**options) = clone.tap { _1.instance_variable_set :@context, @context.merge(**options) }

    def call(name, ...)
      resolved = [@name, @context.arguments, name.to_s, process(...)].flatten
      puts resolved.join(" ")
      system *resolved
    end

    ruby2_keywords def method_missing(name, *arguments)
      arguments.empty? ? Subcommand.new(self, name.dasherize) : call(name, *arguments)
    end

    private
      def process(*arguments, **options)
        arguments.map { option_name _1 } + options.transform_keys { option_name _1 }.flatten
      end

      def option_name(name)
        name.is_a?(Symbol) ? "#{name.size > 1 ? "--" : "-"}#{name.dasherize}" : name
      end
  end

  class Subcommand < Data.define(:adapter, :name)
    def method_missing(...) = call(...)
    def call(...) = adapter.call(name, ...)
  end

  class Context
    def initialize(**options)
      @options = options
      @arguments = @options.map { ["--#{_1.dasherize}", _2.shellescape].join("=") }
    end
    attr_reader :arguments

    def except(*) = self.class.new(**@options.except(*))
    def merge(**options) = self.class.new(**@options, **options)
  end
end
