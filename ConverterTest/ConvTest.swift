//
//  ConvTest.swift
//
//
//  Created by David Jones (@djones6) on 02/06/2016 
//  Modified by Bhaktavatsal Reddy (@mbvreddy) on 07/07/2016
//
//

import Foundation
import Dispatch

// Determine how many concurrent blocks to schedule (user specified, or 10)
var CONCURRENCY:Int = 10

// Determines how many times to convert a string per block
var EFFORT:Int = 1000

// Determines the length of the payload being converted
var LENGTH:Int = 1000

// Debug
var DEBUG = false

func usage() {
  print("Options are:")
  print("  -c, --concurrency n: number of concurrent Dispatch blocks")
  print("  -e, --effort n: number of times to invoke conversion per block")
  print("  -l, --length n: length of String (in chars) to be converted")
  print("  -d, --debug: print a lot of debugging output")
  exit(1)
}

// Parse an expected int value provided on the command line
func parseInt(param: String, value: String) -> Int {
  if let userInput = Int(value) {
    return userInput
  } else {
    print("Invalid value for \(param): '\(value)'")
    exit(1)
  }
}

// Parse command line options
var param:String? = nil
var remainingArgs = Process.arguments.dropFirst(1)
for arg in remainingArgs {
  if let _param = param {
    param = nil
    switch _param {
    case "-c", "--concurrency":
      CONCURRENCY = parseInt(param: _param, value: arg)
    case "-e", "--effort":
      EFFORT = parseInt(param: _param, value: arg)
    case "-l", "--length":
      LENGTH = parseInt(param: _param, value: arg)
    default:
      print("Invalid option '\(arg)'")
      usage()
    }
  } else {
    switch arg {
    case "-c", "--concurrency", "-e", "--effort", "-l", "--length":
      param = arg
    case "-d", "--debug":
      DEBUG = true
    case "-?", "-h", "--help", "--?":
      usage()
    default:
      print("Invalid option '\(arg)'")
      usage()
    }
  }
}

if (DEBUG) {
  print("Concurrency: \(CONCURRENCY)")
  print("Effort: \(EFFORT)")
  print("Length: \(LENGTH)")
  print("Debug: \(DEBUG)")
}
// list of encodings - for SNAPSHOT build upto June 20 2016
/*let ENCODINGS: [UInt] = [NSASCIIStringEncoding,
                         NSNEXTSTEPStringEncoding,
                         NSJapaneseEUCStringEncoding,
                         NSUTF8StringEncoding,
                         NSISOLatin1StringEncoding,
                         NSSymbolStringEncoding,
                         NSNonLossyASCIIStringEncoding,
                         NSShiftJISStringEncoding,
                         NSISOLatin2StringEncoding,
                         NSUnicodeStringEncoding,
                         NSWindowsCP1251StringEncoding,
                         NSWindowsCP1252StringEncoding,
                         NSWindowsCP1253StringEncoding,
                         NSWindowsCP1254StringEncoding,
                         NSWindowsCP1250StringEncoding,
                         NSISO2022JPStringEncoding,
                         NSMacOSRomanStringEncoding,
                         NSUTF16StringEncoding,
                         NSUTF16BigEndianStringEncoding,
                         NSUTF16LittleEndianStringEncoding,
                         NSUTF32StringEncoding,
                         NSUTF32BigEndianStringEncoding,
                         NSUTF32LittleEndianStringEncoding]*/

// list of encodings - to run with latest source
let ENCODINGS: [String.Encoding] = [String.Encoding.ascii,
                                    String.Encoding.nextstep,
                                    String.Encoding.japaneseEUC,
                                    String.Encoding.utf8,
                                    String.Encoding.isoLatin1,
                                    String.Encoding.symbol,
                                    String.Encoding.nonLossyASCII,
                                    String.Encoding.shiftJIS,
                                    String.Encoding.isoLatin2,
                                    String.Encoding.unicode,
                                    String.Encoding.windowsCP1251,
                                    String.Encoding.windowsCP1252,
                                    String.Encoding.windowsCP1253,
                                    String.Encoding.windowsCP1254,
                                    String.Encoding.windowsCP1250,
                                    String.Encoding.iso2022JP,
                                    String.Encoding.macOSRoman,
                                    String.Encoding.utf16,
                                    String.Encoding.utf16BigEndian,
                                    String.Encoding.utf16LittleEndian,
                                    String.Encoding.utf32,
                                    String.Encoding.utf32BigEndian,
                                    String.Encoding.utf32LittleEndian]

// The string to convert
let PAYLOAD:String
var _payload = "Houston we have a problem"
while _payload.characters.count < LENGTH {
  _payload = _payload + _payload
}
// Surely this isn't the best way to substring? but it works...
PAYLOAD = String(_payload.characters.dropLast(_payload.characters.count - LENGTH))
if DEBUG { print("Payload is \(PAYLOAD.characters.count) chars") }

// Create a queue to run blocks in parallel
let queue = DispatchQueue(label: "hello", attributes: .concurrent)


// Block to be scheduled
//func code(_ instance: String, using encoding: UInt) -> () -> Void {
func code(_ instance: String, using encoding: String.Encoding) -> () -> Void {
return {
  for _ in 1...EFFORT {
    let _ = PAYLOAD.data(using: encoding)
  }
  if DEBUG {  print("\(instance) done") }
  // Dispatch a new block to replace this one
    queue.async{
        code("\(instance)+", using: encoding)()
    }
}
}

print("Queueing \(CONCURRENCY) blocks")
for enc in ENCODINGS {
    // Queue the initial blocks
    for i in 1...CONCURRENCY {
        queue.async{
            code("\(i)", using: enc)()
        }
    }
}
print("Go!")

// Go
dispatchMain()
