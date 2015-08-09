require 'rubygems'
require 'xcodeproj'
require 'tmpdir'

@temp_dir = "./lib"

`rm -rf #{@temp_dir}` if Dir.exist? @temp_dir
`mkdir #{@temp_dir}`

app_plist_text = <<eos
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>io.orta.$(PRODUCT_NAME:rfc1034identifier)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
	<key>UIMainStoryboardFile</key>
	<string>Main</string>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>armv7</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
</dict>
</plist>
eos

main_swift = <<eos
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
}
eos

test_plist_text = <<eos
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

class ExampleTests: XCTestCase {

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

app_main_swift_path = @temp_dir + '/Main.swift'
app_plist_path = @temp_dir + '/App-Info.plist'
tests_plist_path = @temp_dir + '/Tests-Info.plist'
tests_swift_path = @temp_dir + '/Tests.swift'
xcodeproject_path = @temp_dir + '/test.xcodeproj'

File.open(app_main_swift_path, 'w') { |f| f.write main_swift }
File.open(app_plist_path, 'w') { |f| f.write app_plist_text }
File.open(tests_plist_path, 'w') { |f| f.write test_plist_text }
File.open(tests_swift_path, 'w') { |f| f.write test_example }

project = Xcodeproj::Project.new xcodeproject_path

# make an app
app_target = project.new_target(:application, 'App', :ios, '8.0', project.main_group, :swift)
main_swift = project.main_group.new_file(Pathname(app_main_swift_path).basename)
app_plist = project.new_file( Pathname(app_plist_path).basename )

app_target.add_file_references([main_swift, app_plist])

# set its info plist right
app_target.build_configurations.each do |c|
    c.build_settings['INFOPLIST_FILE'] = Pathname(app_plist_path).basename
end


# make a unit tests target
test_target = project.new_target(:unit_test_bundle, 'App Tests', :ios, '8.0', project.main_group, :swift)

swift_test = project.new_file( Pathname(tests_swift_path).basename )
test_plist = project.new_file( Pathname(tests_plist_path).basename )

test_target.add_file_references([swift_test, test_plist])
test_target.build_configurations.each do |c|
    c.build_settings['INFOPLIST_FILE'] = Pathname(tests_plist_path).basename
end

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
