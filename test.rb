require "shellwords"

module ProcessSip
  module ExtenSip
    refine Symbol do
      def dasherize
        name.dasherize
      end
    end

    refine String do
      def dasherize
        tr("_", "-")
      end
    end

    refine Enumerable do
      def index_with(default)
        to_h { [ _1, default ] }
      end
    end
  end
  using ExtenSip

  def self.method_missing(command)
    Command.new(command)
  end

  class Command
    def initialize(name)
      @name = name.to_s
      @context = Context.new self
    end

    def with(*keys, **options, &block)
      new_with_context(*keys, **options, &block)
    end

    def without(*keys, &block)
      new_with_context(**@context.without(*keys), &block)
    end

    def exec(command, *arguments, **options, &block)
      if block_given?
        yield self # spawn a process here?
      else
        command = [ @name, *@context.arguments, command.to_s, *process_arguments(arguments), *process_options(options) ]
        p command
        system *command
      end
    end
    alias method_missing exec

    private
      protected attr_accessor :context

      def new_with_context(*keys, **options)
        clone.tap do
          _1.context = Context.new(_1, *keys, **options)
          yield self if block_given?
        end
      end

      def process_arguments(arguments)
        arguments.map { _1.is_a?(Symbol) ? "-#{_1}" : _1 }.map(&:dasherize)
      end

      def process_options(options)
        options.map { "-#{_1.dasherize}=#{_2}" }
      end
  end

  class Context
    attr_reader :arguments

    def initialize(command, *keys, **options)
      @command, @options = command, keys.index_with(nil).merge(options)
      @arguments = @options.map { [ "--#{_1.dasherize}", _2&.shellescape ].compact.join("=") }
    end

    def without(*keys)
      keys.none? ? {} : @options.except(*keys)
    end
  end
end

@git = ProcessSip.git
def @git.commit_all(message)
  add "." and commit :m, message
end

@git_dir = @git.with(git_dir: __dir__)
