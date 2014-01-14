require 'fileutils'

module RXC
  module Rake

    # Invoke an xcodebuild action, using sensible defaults.
    #
    #     xcodebuild
    #     xcodebuild, workspace: 'Foo.xcworkspace', scheme: 'Bar'
    #     xcodebuild 'test'
    #     xcodebuild 'test', colour: false, device: 'iPhone (Retina 4-inch)'
    #
    # - Assumes a CocoaPods-style setup with an xcworkspace and
    #   xcodeproj in the current working directory
    # - Formats output using xcpretty (disable with `pretty: false`)
    # - Defaults to the most recently modified .xcworkspace
    # - Defaults to the first scheme listed in `xcodebuild -list`
    # - When testing, the :device option is passed directly to the
    #   `name` parameter to xcodebuild's `-destination` argument.
    #   Defaults to 'iPad'.
    #
    def xcodebuild(action = 'build', options = {})
      action    = action.to_s
      testing   = action == 'test'

      colour        = options.fetch(:colour)        { true }
      pretty        = options.fetch(:pretty)        { true }
      workspace     = options.fetch(:workspace)     { Dir['*.xcworkspace'].sort_by { |ws| File.new(ws).mtime }.last }
      scheme        = options.fetch(:scheme)        { nil }
      configuration = options.fetch(:configuration) { nil }
      platform      = options.fetch(:platform)      { nil } || 'iOS Simulator'
      device        = options.fetch(:device)        { nil } || 'iPad'
      junit_path    = options.fetch(:junit)         { nil }

      unless scheme
        project_info = {}
        current = nil

        `xcodebuild -list`.each_line do |line|
          case line
          when /^\s+((?:\w+| )+):$/
            current = $1
          when /^\s+.*?(\w+)$/
            project_info[current] ||= []
            project_info[current] << $1
          end
        end

        scheme = project_info['Schemes'].first
      end

      if platform == 'iOS'
        destination = "generic/platform=iOS"
      else
        destination = "platform=#{platform},name=#{device}"
      end

      cmd = "xcodebuild -workspace #{workspace} -scheme #{scheme} -destination '#{destination}'"
      cmd << " -configuration #{configuration}" if configuration
      cmd << " #{action}"

      if pretty
        flags = ''
        flags << 'c' if colour && STDOUT.tty?
        flags << 't' if testing

        options = ''
        options << "-r junit -o #{junit_path}" if junit_path && testing

        cmd << " | xcpretty#{' -' + flags unless flags.empty?}"
        cmd << " #{options}" unless options.empty?
      end

      sh cmd
    end

    def package(codesign_identity: nil, output_dir: 'Package')
      built_product = Dir['Build/Products/*/*.app'].sort_by { |f| File.new(f).mtime }.last
      app_name = File.basename(built_product, File.extname(built_product))
      output_file = File.join(Dir.pwd, output_dir, '%s.ipa' % app_name)

      cmd = "xcrun -sdk iphoneos PackageApplication -v #{built_product} -o #{output_file}"
      cmd << " -s '#{codesign_identity}'" if codesign_identity

      sh cmd
    end

  end
end
