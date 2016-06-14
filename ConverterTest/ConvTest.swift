//
//  ConvTest.swift
//
//
//  Created by David Jones (@djones6) on 02/06/2016 
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
let queue = dispatch_queue_create("hello", DISPATCH_QUEUE_CONCURRENT)

// Block to be scheduled
func code(_ instance: String) -> () -> Void {
return {
  for _ in 1...EFFORT {
    let _ = PAYLOAD.data(using: NSUTF8StringEncoding)
  }
  if DEBUG {  print("\(instance) done") }
  // Dispatch a new block to replace this one
  dispatch_async(queue, code("\(instance)+"))
}
}

print("Queueing \(CONCURRENCY) blocks")

// Queue the initial blocks
for i in 1...CONCURRENCY {
  dispatch_async(queue, code("\(i)"))
}

print("Go!")

// Go
dispatch_main()
