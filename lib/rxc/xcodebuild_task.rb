require 'rake'
require 'rake/tasklib'

require_relative 'command_builder'
require_relative 'project_info'

module RXC

  # Create tasks for working with Xcode projects.
  class XcodebuildTask < ::Rake::TaskLib

    attr_accessor :name

    attr_accessor :runner

    attr_accessor :pretty

    attr_accessor :xcodeproj

    attr_accessor :workspace

    attr_accessor :scheme

    attr_accessor :clean_paths

    # True if the build task should look for a default scheme (which is
    # slower than explicitly setting a scheme). Set this to false for a
    # performance boost if your .xcodeproj doesn't require a scheme in
    # order to build. (default is true)
    attr_accessor :find_schemes

    alias_method  :find_schemes?, :find_schemes; private :find_schemes?

    def initialize(name = nil)
      @name = name
      @runner = 'xcodebuild'
      @pretty = true
      @find_schemes = true
      yield self if block_given?
      define
      self
    end

    def define
      desc "Build the project"
      task :build do |task|
        cmd = CommandBuilder.new do |c|
          c.add { runner }
          c.add { build_options }
          c.add { task.name }
          c.add public_method(:formatter_options)
        end

        sh(cmd.to_s)
      end

      desc "Clean the project"
      if clean_paths.empty?
        task :clean do
          sh 'xcodebuild', *clean_options, 'clean'
        end
      else
        task :clean => [:clobber]
        task :clobber do
          Dir.glob(*clean_paths).each do |path|
            rm_rf path
          end
        end
      end
    end

    def clean_paths
      @clean_paths ||= []
    end

    def clean_paths=(*paths)
      @clean_paths = paths.flatten
    end

    def build_options
      [].tap do |opts|
        if workspace
          opts.push '-workspace', workspace
        elsif xcodeproj
          opts.push '-project', xcodeproj
        end

        if scheme
          opts.push '-scheme', scheme
        end
      end
    end

    def formatter_options(cmd)
      # return nil unless pretty
      return nil unless pretty && cmd.any? { |str| str.include? 'xcpretty' }

      ['| xcpretty'].tap do |format_cmd|
        format_cmd << '-t' if cmd.include? 'test'
        format_cmd << '-c' if $stdout.tty?
      end
    end

    def workspace
      if (@workspace ||= find_workspace) == :noworkspace
        nil
      else
        @workspace
      end
    end

    def find_workspace
      project_info.workspace || :noworkspace
    end

    def scheme
      if (@scheme ||= find_schemes? ? find_scheme : :noscheme) == :noscheme
        unless find_schemes?
          $stderr.puts "Automatically find schemes is disabled"
        end
        nil
      else
        @scheme
      end
    end

    def find_scheme
      (project_info.find!.scheme || :noscheme).tap do |scheme|
        $stderr.puts "Found scheme #{scheme}" unless scheme == :noscheme
      end
    end

    def project_info
      @project_info ||= ProjectInfo.new(name: name)
    end

  end

end
