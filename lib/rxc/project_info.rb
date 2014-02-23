module RXC

  class ProjectInfo

    # The name of the primary Xcode project. If not specified,
    # `xcodebuild`'s default will be used.
    attr_reader :name

    # The xcode project. This attribute will be nil if `name` is nil.
    attr_reader :xcodeproj

    # A list of workspaces located in the project directory.
    attr_reader :workspaces

    # A list of schemes in the primary Xcode project.
    attr_reader :schemes

    # The default workspace. (first in workspaces)
    attr_reader :workspace

    # The default scheme. (first in schemes)
    attr_reader :scheme

    # The base directory in which to look for project information.
    # (defaults to the current working directory)
    attr_reader :basedir

    def initialize(name: nil, basedir: Dir.pwd)
      @name = resolve_name(name)
      @basedir = basedir
    end

    def resolve_name(name)
      # If a project name is not explicitly provided
      return nil unless name

      projects = Dir["{#{name},*}.xcodeproj"]
      projects.empty? ? nil : projects.first.sub(/\.xcodeproj$/, '')
    end
    private :resolve_name

    def xcodeproj
      name ? "#{name}.xcodeproj" : nil
    end

    def workspaces
      data['Workspaces'].tap do |workspaces|
        if workspaces.empty?
          in_project_dir do
            Dir["{#{name},*}.xcworkspace"].each { |w| workspaces << w }
          end
        end
      end
    end

    def workspace
      workspaces.empty? ? nil : workspaces.first
    end

    def schemes
      data['Schemes']
    end

    def scheme
      schemes.empty? ? nil : schemes.first
    end

    def data
      @data ||= @project_info || empty_data
    end

    def find!
      @project_info ||= find_project_info
      data.merge!(@project_info)
      self
    end

    private

    # Parses the output of `xcodebuild -list` into a hash with keys
    # corresponding to each section of output, each containing an
    # array of items. In the case that there are no items in a certain
    # section, an empty is guaranteed to be returned.
    def find_project_info
      {}.tap do |project_info|
        current_category = nil
        in_project_dir do
          %x(xcodebuild -list).each_line do |line|
            case line
            when /^\s+((?:\w+| )+):$/
              current_category = $1
            when /^\s+.*?(\w+)$/
              project_info[current_category] ||= []
              project_info[current_category] << $1
            end
          end
        end
      end
    end

    # Perform the block from within `basedir`.
    def in_project_dir(&block)
      Dir.chdir(basedir, &block)
    end

    # Create a new hash that returns an empty array for missing keys.
    def empty_data
      Hash.new([])
    end

  end

end
