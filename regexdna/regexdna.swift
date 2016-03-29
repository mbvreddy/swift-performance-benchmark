//
//  regex-dna.swift
//
//
//  Created by Bhaktavatsal Reddy on 28/03/16.
//
//

import Foundation
import Dispatch

// Parse command line arguments
let inputFile: String
if Process.arguments.count > 1 {
    inputFile = String(Process.arguments[1]) ?? "/home/ubuntu/mbvreddy/file.txt"
} else {
    inputFile = "/home/ubuntu/mbvreddy/file.txt"
}

var data:NSString?
do {
    data = try NSString(contentsOfFile: inputFile, encoding: NSASCIIStringEncoding)
} catch {
    print("error reading file \(inputFile). Please ensure absolute path to file is passed")
}

var mdata = data ?? ""
let initialLength = mdata.length

let sequence = mdata.stringByReplacingOccurrencesOfString("\n", withString: "")

let codeLength = sequence.characters.count

print("\(initialLength)")

let replacements = [ "W" : "(a|t)",
                     "Y" : "(c|t)",
                     "K" : "(g|t)",
                     "M" : "(a|c)",
                     "S" : "(c|g)",
                     "R" : "(a|g)",
                     "B" : "(c|g|t)",
                     "D" : "(a|g|t)",
                     "V" : "(a|c|g)",
                     "H" : "(a|c|t)",
                     "N" : "(a|c|g|t)"]

let variants = 	[ "agggtaaa|tttaccct",
               	  "[cgt]gggtaaa|tttaccc[acg]",
               	  "a[act]ggtaaa|tttacc[agt]t",
               	  "ag[act]gtaaa|tttac[agt]ct",
               	  "agg[act]taaa|ttta[agt]cct",
               	  "aggg[acg]aaa|ttt[cgt]ccct",
               	  "agggt[cgt]aa|tt[acg]accct",
               	  "agggta[cgt]a|t[acg]taccct",
               	  "agggtaa[cgt]|[acg]ttaccct" ]
var results = [String:Int]()

let notified = dispatch_semaphore_create(0)

let group = dispatch_group_create()
let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

for v in variants {
    let regex = try NSRegularExpression(pattern: v, options: [])
    dispatch_group_async(group, queue) {
        let matchCount = regex.numberOfMatchesInString(sequence, options: [], range: NSMakeRange(0,codeLength))
        results[v] = matchCount
        print("task complete")
    }
}

dispatch_group_notify(group, queue) {
    // This block will be executed when all tasks are complete
    print("All tasks complete")
    dispatch_semaphore_signal(notified)
}

// Block this thread until all tasks are complete
dispatch_group_wait(group, DISPATCH_TIME_FOREVER)

// Wait until the notify block signals our semaphore
dispatch_semaphore_wait(notified, DISPATCH_TIME_FOREVER)


for v in variants {
    print("\(v) -- \(results[v] ?? 0)")
}

//TODO
//Fix replacing matched pattern with corresponding value from replacements Dictionary.
//Currently, replacements["$0"] always return nil and is replaced with 'XX'
let regex = try NSRegularExpression(pattern: "[WYKMSRBDVHN]", options: [])
let replacedString = regex.stringByReplacingMatchesInString(sequence, options:[], range: NSMakeRange(0,sequence.characters.count), withTemplate: replacements["$0"] ?? "XX")
print("\(replacedString.dynamicType) has length \(replacedString.characters.count)")