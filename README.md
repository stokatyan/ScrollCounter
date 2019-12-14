# ScrollCounter

[![Version](https://img.shields.io/cocoapods/v/ScrollCounter.svg?style=flat)](https://cocoapods.org/pods/ScrollCounter)
[![License](https://img.shields.io/cocoapods/l/ScrollCounter.svg?style=flat)](https://cocoapods.org/pods/ScrollCounter)
[![Platform](https://img.shields.io/cocoapods/p/ScrollCounter.svg?style=flat)](https://cocoapods.org/pods/ScrollCounter)

## Installation
ScrollCounter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:
```ruby
pod 'ScrollCounter'
```

## Usage
ScrollCounter is a framework for getting a nice scrolling animation when transitioning between numbers.  This framework is modeled after the animations seen in the Robinhood app.

Checkout [this Medium article](https://medium.com/@tokat.shant/scrollcounter-an-ios-solution-to-the-robinhood-number-animation-bbcbd8c90355) for a high-level look on how ScrollCounter works.

### Single Digits
<img src="https://github.com/stokatyan/ReadMeMedia/blob/master/ScrollCounter/DigitScrollGif.gif" width="97" height="157" />
A scroll counter with a single digit can be created and animated in 2 lines:

```swift
// Initialize a scrolling counter for the standard range between 0-9 (other ranges can be used as well).
let singleDigit = DigitScrollCounter(font: UIFont(name: "Avenir-Black", size: 150)!, textColor: .white, backgroundColor: .black, scrollDuration: 0.3, gradientColor: .black, gradientStop: 0.2)

// Scrolls to the item at the 8th index.  For a DigitScrollCounter, this means scroll to the number 8.
singleDigit.scrollToItem(atIndex: 8)
```

### Unbounded Numbers
<img src="https://github.com/stokatyan/ReadMeMedia/blob/master/ScrollCounter/NumberScrollingGif.gif" width="264" height="80.8" />
Use a `NumberScrollCounter` to handle an unbounded range of numbers:

```swift
// Initialize a number counter, which is a view composed of `DigitScrollCounter`s.
let numberCounter = NumberScrollCounter(value: 1, scrollDuration: 0.33, decimalPlaces: 2, prefix: "$", suffix: "", font: font.withSize(40), textColor: .white, gradientColor: .black, gradientStop: 0.2)

// Set a new value.  This will trigger the animation to show the given value.
numberCounter.setValue(123.45)
```
