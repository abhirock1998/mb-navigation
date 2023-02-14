require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

TargetsToChangeToDynamic = []

$RNMBNAV = Object.new

def $RNMBNAV.post_install(installer)
  installer.pod_targets.each do |pod|
    if TargetsToChangeToDynamic.include?(pod.name)
      if pod.send(:build_type) != Pod::BuildType.dynamic_framework
        pod.instance_variable_set(:@build_type,Pod::BuildType.dynamic_framework)
        puts "* Changed #{pod.name} to `#{pod.send(:build_type)}`"
        fail "Unable to change build_type" unless mobile_events_target.send(:build_type) == Pod::BuildType.dynamic_framework
      end
    end
  end
end

def $RNMBNAV.pre_install(installer)
  installer.aggregate_targets.each do |target|
    target.pod_targets.select { |p| TargetsToChangeToDynamic.include?(p.name) }.each do |mobile_events_target|
      mobile_events_target.instance_variable_set(:@build_type,Pod::BuildType.dynamic_framework)
      puts "* Changed #{mobile_events_target.name} to #{mobile_events_target.send(:build_type)}"
      fail "Unable to change build_type" unless mobile_events_target.send(:build_type) == Pod::BuildType.dynamic_framework
    end
  end
end




Pod::Spec.new do |s|
  s.name         = "react-native-mb-navigation"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-mb-navigation
                   DESC
  s.homepage     = "https://github.com/abhirock1998/mb-navigation"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Your Name" => "yourname@email.com" }
  s.platforms    = { :ios => "13.0" }
  s.source       = { :git => "https://github.com/abhirock1998/mb-navigation.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,cc,cpp,m,mm,swift}"
  s.requires_arc = true

  s.dependency "React-Core"
  # s.dependency "MapboxNavigation", "~> 2.9.0"
  s.dependency "MapboxNavigation", "~> 2.1.0"
  s.dependency "MapboxMobileEvents", "~> 1.0"
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end

