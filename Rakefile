require "bundler/gem_tasks"

# disable rubygems push on release
ENV['gem_push'] = '0'

task :geminabox_source do
  host = "http://growmoney.local:9292"
  unless `gem sources`.include? host
    sh "gem sources -a #{host}"
  end
end

# extend release task to push to `gem_host` instead of RubyGems
task :release => :geminabox_source do
  built_gem = Dir['pkg/*.gem'].sort_by { |g| File.new(g).mtime }.last
  overwrite = ENV['GEM_OVERWRITE'] == '1'
  sh "gem inabox#{' -o' if overwrite} #{built_gem}"
end
