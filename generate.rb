require 'rubygems'
require 'xcodeproj'
require 'tmpdir'

@temp_dir = "./lib"

`rm -rf #{@temp_dir}` if Dir.exist? @temp_dir
`mkdir #{@temp_dir}`

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

test_example = <<eos
import UIKit
import XCTest

class Mpore_TEsts: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
eos

File.open(@temp_dir + '/Main.swift', 'w') { |f| f.write main_swift }
File.open(@temp_dir + '/Tests-Info.plist', 'w') { |f| f.write main_swift }
File.open(@temp_dir + '/Tests.swift', 'w') { |f| f.write test_example }

project = Xcodeproj::Project.new(@temp_dir + '/test.xcodeproj')
app_target = project.new_target(:application, 'App', :ios, '8.0', project.main_group, :swift)

main_swift = project.main_group.new_file('./Main.swift')
app_target.add_file_references([main_swift])

test_target = project.new_target(:unit_test_bundle, 'App Tests', :ios, '8.0', project.main_group, :swift)

swift_test = project.new_file("./Tests.swift", :group)
test_target.add_file_references([swift_test])

# Add an info.plist to the tests target

# Set up the schemes
test_action = Xcodeproj::XCScheme::TestAction.new()
test_ref = Xcodeproj::XCScheme::TestAction::TestableReference.new(test_target)

# might not need this
app_test_action = Xcodeproj::XCScheme::TestAction.new()
app_test_ref = Xcodeproj::XCScheme::TestAction::TestableReference.new(app_target)

# Make the app test schemes use the right unit testing bundle

project.recreate_user_schemes

project.save()
