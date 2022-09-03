require_relative "lib/process_sip"

git = ProcessSip.git
define_method(:git) { git }
def git.commit_all(message)
  add "." and commit :m, message
end

git_dir = git.with(git_dir: __dir__)
define_method(:git_dir) { git_dir }
