# Purpose
BLEListerSwift is an iOS application that lists Bluetooth Low Energy devices.

# App Requirements

## iOS
An iOS device with Bluetooth Low Energy (BLE). E.g. iPhone >= 4s.
iOS 10.3 or newer.

# References

## Performing Common Central Role Tasks 
https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/PerformingCommonCentralRoleTasks/PerformingCommonCentralRoleTasks.html

## Objective C Examples
BLELister
https://github.com/beepscore/BLELister

### Apple BLE example project BTLE Transfer
### Apple BLE example project TemperatureSensor

## Swift examples
https://wingoodharry.wordpress.com/2016/01/21/get-list-of-ble-devices-using-corebluetooth-on-ios-swift/

https://www.raywenderlich.com/85900/arduino-tutorial-integrating-bluetooth-le-ios-swift

## GATT Services
https://developer.bluetooth.org/gatt/services/Pages/ServicesHome.aspx

http://stackoverflow.com/questions/26061359/readrssi-doesnt-call-the-delegate-method?lq=1

## TI SensorTag
UUID can change depending upon iOS central device?
https://e2e.ti.com/support/wireless_connectivity/f/538/t/199289

# Results

## Unit tests
At one point unit tests quickly exited and failed with log message:
"xcode failed to establish communication with the test runner".
Fixed this by turning iPhone off and then on.
https://stackoverflow.com/questions/53643318/xctests-canceling-prematurely
