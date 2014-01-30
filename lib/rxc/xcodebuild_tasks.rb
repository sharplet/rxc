require 'rake'
require_relative 'rake'

# ================
# = Dependencies =
# ================

desc "Alias for deps:install"
task :deps => ['deps:install']

namespace :deps do
  # Define a bundler task that will only run if Gemfile exists
  def bundle_task(*args, &block)
    task(*args) do |task, args|
      if bundler?
        yield task, args
      else
        if Rake.application.options.trace
          Rake.application.trace "Nothing to do for task '#{task.name}' (no Gemfile in current directory)"
        end
      end
    end
  end
  private :bundle_task

  # Try to bundle exec a command if Gemfile exists, otherwise execute directly
  def bundle_sh(cmd)
    cmd = (bundler? ? "bundle exec " : "") + cmd
    sh(cmd)
  end
  private :bundle_sh

  def bundler?
    File.exist?('Gemfile')
  end
  private :bundler?

  desc "Install dependencies"
  task :install => [:install_bundle, :install_pods]

  bundle_task :install_bundle do
    sh "bundle install"
  end

  task :install_pods do
    bundle_sh "pod install#{' --no-color' unless $stdout.tty?}"
  end

  desc "Update dependencies"
  task :update => [:update_bundle, :update_pods]

  bundle_task :update_bundle do
    sh "bundle update"
  end

  task :update_pods do
    bundle_sh "pod update#{' --no-color' unless $stdout.tty?}"
  end
end
