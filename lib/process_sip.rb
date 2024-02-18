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
      @name, @context, @preprint = name.dasherize, Context.new, false
    end

    def omit(*keys)     = clone_with(context: @context.except(*keys))
    def with(**options) = clone_with(context: @context.merge(**options))

    def call(name, *, **, &block)
      chain = [@name, @context.arguments, name.to_s.dasherize, process(*, **)].flatten.map(&:shellescape).join(" ")
      puts chain if @preprint

      IO.popen(chain, &block || -> { _1.read.chomp })
    end

    ruby2_keywords def method_missing(name, *arguments, &block)
      Subcommand.new(self, name).then do |apply|
        if block_given? || arguments.any?
          apply.call(*arguments, &block)
        else
          apply
        end
      end
    end

    def preprint = clone_with(preprint: true)
    def silent   = clone_with(preprint: false)

    private
      def process(*arguments, **options)
        arguments.map { option_name _1 } + options.transform_keys { option_name _1 }.flatten
      end

      def option_name(name)
        name.is_a?(Symbol) ? "#{name.size > 1 ? "--" : "-"}#{name.dasherize}" : name
      end
  end

  class Subcommand < Data.define(:adapter, :name)
    def match?(...) = call.match?(...)
    def readlines(chomp: true) = call { _1.readlines(chomp:) }

    def stream(*, **) = call(*, **) do |io|
      while line = io.gets&.chomp; yield line; end
    end

    def call(...) = adapter.call(name, ...)
    alias method_missing call
    alias read call
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
