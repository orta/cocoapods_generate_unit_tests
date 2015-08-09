require 'rubygems'
require 'xcodeproj'
require 'tmpdir'

@temp_dir = "./lib"

project = Xcodeproj::Project.new(@temp_dir + '/test.xcodeproj')
app_target = project.new_target(:application, 'App', :ios, '8.0', project.main_group, :swift)

main_swift = <<eos
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
}
eos

test_plist = <<eos
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
  	<key>CFBundleDevelopmentRegion</key>
  	<string>en</string>
  	<key>CFBundleExecutable</key>
  	<string>$(EXECUTABLE_NAME)</string>
  	<key>CFBundleIdentifier</key>
  	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
  	<key>CFBundleInfoDictionaryVersion</key>
  	<string>6.0</string>
  	<key>CFBundleName</key>
  	<string>$(PRODUCT_NAME)</string>
  	<key>CFBundlePackageType</key>
  	<string>BNDL</string>
  	<key>CFBundleShortVersionString</key>
  	<string>1.0</string>
  	<key>CFBundleSignature</key>
  	<string>????</string>
  	<key>CFBundleVersion</key>
  	<string>1</string>
  </dict>
</plist>
eos

File.open(@temp_dir + '/Main.swift', 'w') { |f| f.write main_swift }
File.open(@temp_dir + '/Tests-Info.plist', 'w') { |f| f.write main_swift }

main_swift = project.main_group.new_file('./Main.swift')
app_target.add_file_references([main_swift])

test_target = project.new_target(:unit_test_bundle, 'App Tests', :ios, '8.0', project.main_group, :swift)

file_name = 'test.m'
file = project.new_file(file_name, :group)

test_target.add_file_references([file])


app_target.configure_with_targets

project.recreate_user_schemes

project.save()
