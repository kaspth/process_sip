# ProcessSip

ProcessSip lets you make ad-hoc adapters for CLIs to interface with from Ruby.

Here's wrapping `git`:

```ruby
git = ProcessSip.git # Connect an adapter to an executable, here `git`.

# Any subcommands are automatically proxied, so:
git.branch.call    # Calls `git branch` on the commandline.
git.branch :remote # Automatically calls when passed arguments, `git branch --remote`.
git.branch :r # `git branch -r`. 1-count symbols get prefixed with -, while anything else gets --.

git.branch :show_current # Get the current branch: `git branch --show-current`.

git.diff.call # `git diff`
git.status :name_only # `git diff --name-only`
```

And here's `bundle`:

```ruby
# Run `bundle install` and stream each line into the block:
ProcessSip.bundle.install.stream do |line|
  puts line
end

ProcessSip.bundle.update.call          # `bundle update`
ProcessSip.bundle.update :only_bundler # `bundle update --only-bundler`

ProcessSip.gem.update :system # `gem update --system`
```

The real power of ProcessSip is to extend the default proxying with your ad-hoc needs. So you can extend the `git` adapter like this:

```ruby
# Open an adapter for a specific executable, here `git`.
ProcessSip.git do
  def commit_all(message)
    add "." and commit message
  end

  def commit(message)
    super :m, message
  end

  def with_work_tree = with(work_tree: __dir__)
  def with_git_dir   = with(git_dir: __dir__ + "/.git")
end

git = ProcessSip.git.with_work_tree.with_git_dir

# Now every git command will use the --work-tree and --git-dir context arguments
git.branch.call # `git --work-tree= --git-dir branch`

deleted_lines = git.diff.select { _1.start_with?("- ") } # `git --work-tree= --git-dir diff`
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add process_sip

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install process_sip

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kaspth/process_sip.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
