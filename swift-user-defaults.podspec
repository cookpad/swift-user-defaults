Pod::Spec.new do |s|
  s.name = "swift-user-defaults"
  s.module_name = "SwiftUserDefaults"
  s.version = "0.0.5"
  s.summary = "A series of Swift friendly utilities for Foundation's UserDefaults class"
  s.homepage = "https://github.com/cookpad/swift-user-defaults"
  s.license = { :type => "MIT", :file => "LICENSE.txt" }
  s.authors = { 'Liam Nichols' => 'liam.nichols.ln@gmail.com', 'Ryan Paterson' => 'ryan-paterson@cookpad.com' }
  s.source = { :git => "https://github.com/cookpad/swift-user-defaults.git", :tag => "#{s.version}" }
  s.source_files = "Sources/**/*.{swift}"
  s.resource_bundles = {'SwiftUserDefaults' => ['Sources/SwiftUserDefaults/PrivacyInfo.xcprivacy']}
  s.swift_version = "5.3"

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '11.0'
  s.watchos.deployment_target = '7'

  # Run Unit Tests
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift}'
  end
end
