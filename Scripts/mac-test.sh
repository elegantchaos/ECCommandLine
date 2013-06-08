echo Testing Mac

base=`dirname $0`
common="$base/../../ECUnitTests/Scripts/"
source "$common/test-common.sh"

xcodebuild -workspace "ECCore.xcworkspace" -scheme "ECCoreMac" -configuration "$testConfig" -sdk "$testSDKMac" clean build test | "$common/$testConvertOutput"
