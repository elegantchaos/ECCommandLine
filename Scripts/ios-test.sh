echo Testing IOS

base=`dirname $0`
common="$base/../../ECUnitTests/Scripts/"
source "$common/test-common.sh"
xcoderoot=`xcode-select --print-path`
xcodebuild="$xcoderoot/usr/bin/xcodebuild"

xcodebuild -workspace "ECCore.xcworkspace" -scheme "ECCoreIOS" -configuration "Debug" -sdk "iphonesimulator" -arch armv7 test | "$common/$testConvertOutput"


#"$xcodebuild" -workspace "ECCore.xcworkspace" -scheme "ECCoreIOS" -configuration "$testConfig" -sdk "$testSDKiOS" test | "$common/$testConvertOutput"
#xcodebuild -target "ECCoreIOS" -configuration "$testConfig" -sdk "$testSDKiOS" $testOptions | "$common/$testConvertOutput"
#xcodebuild -target "ECCoreIOSTests" -configuration "$testConfig" -sdk "$testSDKiOS" $testOptions | "$common/$testConvertOutput"



