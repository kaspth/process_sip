require_relative "lib/process_sip"

# lib/process_sip/executables/git.rb
git = ProcessSip.git do
  def commit_all(message)
    add "." and commit message
  end

  def commit(message)
    super :m, message
  end
end
p git

git = ProcessSip.git do
  def with_work_tree = with(work_tree: __dir__)
  def with_git_dir   = with(git_dir: __dir__ + "/.git")
end
p git

git = ProcessSip.git.preprint
p git
define_method(:git) { git }

binding.irb

# git.with_work_tree.with(git_dir: __dir__ + "/.git").omit(:git_dir, :work_tree)
# git.with_work_tree.with_git_dir.omit(:git_dir, :work_tree)
# git.with_work_tree.silent.preprint.branch :d, "branch"

# def git.commit(message) = super(:m, message)
#
# def git.commit_all(message)
#   add "." and commit message
# end
#
# git_dir = git.with(git_dir: __dir__)
# define_method(:git_dir) { git_dir }
