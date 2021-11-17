Pod::Spec.new do |s|
  s.name = "SwiftUserDefaults"
  s.version = "0.0.1"
  s.summary = "A series of Swift friendly utilities for Foundation's UserDefaults class"
  s.homepage = "https://github.com/cookpad/swift-user-defaults"
  s.license = { :type => "MIT", :file => "LICENSE.txt" }
  s.authors = { 'Liam Nichols' => 'liam.nichols.ln@gmail.com', 'Ryan Paterson' => 'ryan-paterson@cookpad.com' }
  s.source = { :git => "https://github.com/cookpad/swift-user-defaults.git", :tag => "v#{s.version}" }
  s.source_files = "Sources/**/*.{swift}"
  s.swift_version = "5.3"

  # iOS deployment target needs to be at minimum iOS 14 so SwiftUI library references compile during `pod lib lint`.
  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '10.12'

  # Run Unit Tests
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift}'
  end
end
