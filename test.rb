require_relative "lib/process_sip"

# lib/process_sip/executables/git.rb
ProcessSip.extension_for :git do
  def commit_all(message)
    add "." and commit message
  end

  def commit(message)
    super :m, message
  end

  def with_work_tree
    @with_work_tree ||= with(work_tree: __dir__)
  end
end

git = ProcessSip.git
define_method(:git) { git }

# def git.commit(message) = super(:m, message)
#
# def git.commit_all(message)
#   add "." and commit message
# end
#
# git_dir = git.with(git_dir: __dir__)
# define_method(:git_dir) { git_dir }
