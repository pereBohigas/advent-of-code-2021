// --- Day 8: Seven Segment Search ---
//
// You barely reach the safety of the cave when the whale smashes into the cave mouth, collapsing it. Sensors indicate another exit to this cave at a much greater depth, so you have no choice but to press on.
//
// As your submarine slowly makes its way through the cave system, you notice that the four-digit seven-segment displays in your submarine are malfunctioning; they must have been damaged during the escape. You'll be in a lot of trouble without them, so you'd better figure out what's wrong.
//
// Each digit of a seven-segment display is rendered by turning on or off any of seven segments named a through g:
//
//   0:      1:      2:      3:      4:
//  aaaa    ....    aaaa    aaaa    ....
// b    c  .    c  .    c  .    c  b    c
// b    c  .    c  .    c  .    c  b    c
//  ....    ....    dddd    dddd    dddd
// e    f  .    f  e    .  .    f  .    f
// e    f  .    f  e    .  .    f  .    f
//  gggg    ....    gggg    gggg    ....
//
//   5:      6:      7:      8:      9:
//  aaaa    aaaa    aaaa    aaaa    aaaa
// b    .  b    .  .    c  b    c  b    c
// b    .  b    .  .    c  b    c  b    c
//  dddd    dddd    ....    dddd    dddd
// .    f  e    f  .    f  e    f  .    f
// .    f  e    f  .    f  e    f  .    f
//  gggg    gggg    ....    gggg    gggg
//
// So, to render a 1, only segments c and f would be turned on; the rest would be off. To render a 7, only segments a, c, and f would be turned on.
//
// The problem is that the signals which control the segments have been mixed up on each display. The submarine is still trying to display numbers by producing output on signal wires a through g, but those wires are connected to segments randomly. Worse, the wire/segment connections are mixed up separately for each four-digit display! (All of the digits within a display use the same connections, though.)
//
// So, you might know that only signal wires b and g are turned on, but that doesn't mean segments b and g are turned on: the only digit that uses two segments is 1, so it must mean segments c and f are meant to be on. With just that information, you still can't tell which wire (b/g) goes to which segment (c/f). For that, you'll need to collect more information.
//
// For each display, you watch the changing signals for a while, make a note of all ten unique signal patterns you see, and then write down a single four digit output value (your puzzle input). Using the signal patterns, you should be able to work out which pattern corresponds to which digit.
//
// For example, here is what you might see in a single entry in your notes:
//
// acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab |
// cdfeb fcadb cdfeb cdbaf
//
// (The entry is wrapped here to two lines so it fits; in your notes, it will all be on a single line.)
//
// Each entry consists of ten unique signal patterns, a | delimiter, and finally the four digit output value. Within an entry, the same wire/segment connections are used (but you don't know what the connections actually are). The unique signal patterns correspond to the ten different ways the submarine tries to render a digit using the current wire/segment connections. Because 7 is the only digit that uses three segments, dab in the above example means that to render a 7, signal lines d, a, and b are on. Because 4 is the only digit that uses four segments, eafb means that to render a 4, signal lines e, a, f, and b are on.
//
// Using this information, you should be able to work out which combination of signal wires corresponds to each of the ten digits. Then, you can decode the four digit output value. Unfortunately, in the above example, all of the digits in the output value (cdfeb fcadb cdfeb cdbaf) use five segments and are more difficult to deduce.
//
// For now, focus on the easy digits. Consider this larger example:
//
// be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb |
// fdgacbe cefdb cefbgd gcbe
// edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec |
// fcgedb cgb dgebacf gc
// fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef |
// cg cg fdcagb cbg
// fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega |
// efabcd cedba gadfec cb
// aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga |
// gecf egdcabf bgf bfgea
// fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf |
// gebdcfa ecba ca fadegcb
// dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf |
// cefg dcbef fcge gbcadfe
// bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd |
// ed bcgafe cdgba cbgef
// egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg |
// gbdfcae bgc cg cgb
// gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc |
// fgae cfgab fg bagce
//
// Because the digits 1, 4, 7, and 8 each use a unique number of segments, you should be able to tell which combinations of signals correspond to those digits. Counting only digits in the output values (the part after | on each line), in the above example, there are 26 instances of digits that use a unique number of segments (highlighted above).
//
// In the output values, how many times do digits 1, 4, 7, or 8 appear?
//
// from: https://adventofcode.com/2021/day/8

// Input:

import Foundation

let inputFileName = #filePath.replacingOccurrences(of: ".swift", with: "_input.txt")

let input = try! String(contentsOfFile: inputFileName)

typealias Entry = (signalLines: [String], outputValue: [String])

let entries: [Entry] = input.split(separator: "\n")
  .map {
    $0.split(separator: "|")
      .map { $0.split(separator: " ").compactMap(String.init) }
  }
  .map { ($0[0], $0[1]) }

// from: https://adventofcode.com/2021/day/8/input

let testData: [Entry] = [
  "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe",
  "edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc",
  "fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg",
  "fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb",
  "aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea",
  "fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb",
  "dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe",
  "bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef",
  "egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb",
  "gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce"
  ]
  .map {
    $0.split(separator: "|")
      .map { $0.split(separator: " ").compactMap(String.init) }
  }
  .map { ($0[0], $0[1]) }

// Solution Part One:

let segmentsQuantityForDigit = [2: 1, 4: 4, 3: 7, 7: 8]

let foundDigits: [[Int]] = entries.compactMap {
    $0.outputValue.compactMap { outputDigit in
      if segmentsQuantityForDigit.keys.contains(outputDigit.count) {
        return segmentsQuantityForDigit[outputDigit.count]
      }
      return nil
    }
  }

let quantityOfFoundDigits = foundDigits.map { $0.count }.reduce(0, +)

print("Answer (part one) - Quantity of '1', '4', '7' and '8': \(quantityOfFoundDigits)")

// --- Part Two ---
//
// Through a little deduction, you should now be able to determine the remaining digits. Consider again the first example above:
//
// acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab |
// cdfeb fcadb cdfeb cdbaf
//
// After some careful analysis, the mapping between signal wires and segments only make sense in the following configuration:
//
//  dddd
// e    a
// e    a
//  ffff
// g    b
// g    b
//  cccc
//
// So, the unique signal patterns would correspond to the following digits:
//
//   - acedgfb: 8
//   - cdfbe: 5
//   - gcdfa: 2
//   - fbcad: 3
//   - dab: 7
//   - cefabd: 9
//   - cdfgeb: 6
//   - eafb: 4
//   - cagedb: 0
//   - ab: 1
//
// Then, the four digits of the output value can be decoded:
//
//   - cdfeb: 5
//   - fcadb: 3
//   - cdfeb: 5
//   - cdbaf: 3
//   - Therefore, the output value for this entry is 5353.
//
// Following this same process for each entry in the second, larger example above, the output value of each entry can be determined:
//
//   - fdgacbe cefdb cefbgd gcbe: 8394
//   - fcgedb cgb dgebacf gc: 9781
//   - cg cg fdcagb cbg: 1197
//   - efabcd cedba gadfec cb: 9361
//   - gecf egdcabf bgf bfgea: 4873
//   - gebdcfa ecba ca fadegcb: 8418
//   - cefg dcbef fcge gbcadfe: 4548
//   - ed bcgafe cdgba cbgef: 1625
//   - gbdfcae bgc cg cgb: 8717
//   - fgae cfgab fg bagce: 4315
//
// Adding all of the output values in this larger example produces 61229.
//
// For each entry, determine all of the wire/segment connections and decode the four-digit output values. What do you get if you add up all of the output values?
//
// from: https://adventofcode.com/2021/day/8#part2

// Solution Part Two:

//  aaaa
// b    c
// b    c
//  dddd
// e    f
// e    f
//  gggg

let segmentsQuantityForDigit2 = [2: [1], 3: [7], 4: [4], 5: [2, 3, 5], 6: [0, 6, 9], 7: [8]]

// Extract number 3 from [2, 3, 5] using 1
let extractNumber3 = { (candidates: [String], number1: String) -> String? in
  let number1Characters = CharacterSet(charactersIn: number1)
  return candidates.filter { candidate in
    number1Characters.isSubset(of: CharacterSet(charactersIn: candidate))
  }.first
}

// Extract number 9 from [0, 6, 9] using 3 and 4
let extractNumber9 = { (candidates: [String], number3: String, number4: String) -> String? in
  let number3Characters = CharacterSet(charactersIn: number3)
  let number4Characters = CharacterSet(charactersIn: number4)

  return candidates.filter { candidate in
    let candidateCharacters = CharacterSet(charactersIn: candidate)

    return candidateCharacters.isSuperset(of: number3Characters.union(number4Characters))
  }.first
}

// Extract number 0 from [6, 0] using 1
let extractNumber0 = { (candidates: [String], number1: String) -> String? in
  let number1Characters = CharacterSet(charactersIn: number1)

  return candidates.filter { candidate in
    number1Characters.isSubset(of: CharacterSet(charactersIn: candidate))
  }.first
}

// Extract number 5 from [2, 5] using 1 and 9
let extractNumber5 = { (candidates: [String], number1: String, number9: String) -> String? in
  let number1Characters = CharacterSet(charactersIn: number1)
  let number9Characters = CharacterSet(charactersIn: number9)

  return candidates.filter { candidate in
    let candidateCharacters = CharacterSet(charactersIn: candidate)
    return number9Characters.isSuperset(of: number1Characters.union(candidateCharacters))
  }.first
}

let entriesCandidates: [[Int:[String]]] = testData.map { entry -> [Int:[String]] in
  var candidates: [Int:[String]] = Dictionary(uniqueKeysWithValues: (0...9).map { ($0, []) } )

  entry.signalLines.forEach { (signalLine: String) in
    let probableNumbers: [Int] = segmentsQuantityForDigit2[signalLine.count]!

    probableNumbers.forEach { probableNumber in
      let currentDigitOptions: [String] = candidates[probableNumber]! + [signalLine]
      candidates.updateValue(currentDigitOptions, forKey: probableNumber)
    }
  }

  return candidates
}

let result: [[Int:[String]]] = entriesCandidates.map { entry -> [Int:[String]] in
  var mutableEntry = entry

  entry.forEach { candidate in
    if candidate.key == 3 {
      let number1 = entry[1]!.first!
      let number3 = extractNumber3(candidate.value, number1)!
      mutableEntry.updateValue([number3], forKey: 3)
      mutableEntry[2]!.removeAll { $0 == number3 }
      mutableEntry[5]!.removeAll { $0 == number3 }
    }
  }

  entry.forEach { candidate in
    if candidate.key == 9 {
      let number3 = mutableEntry[3]!.first!
      let number4 = entry[4]!.first!
      let number9 = extractNumber9(candidate.value, number3, number4)!
      mutableEntry.updateValue([number9], forKey: 9)
      mutableEntry[0]!.removeAll { $0 == number9 }
      mutableEntry[6]!.removeAll { $0 == number9 }
    }
  }

  entry.forEach { candidate in
    if candidate.key == 0 {
      let number1 = entry[1]!.first!
      let number0 = extractNumber0(candidate.value, number1)!
      mutableEntry.updateValue([number0], forKey: 0)
      mutableEntry[6]!.removeAll { $0 == number0 }
    }
  }

  entry.forEach { candidate in
    if candidate.key == 5 {
      let number1 = entry[1]!.first!
      let number9 = mutableEntry[9]!.first!
      let number5 = extractNumber5(candidate.value, number1, number9)!
      mutableEntry.updateValue([number5], forKey: 5)
      mutableEntry[2]!.removeAll { $0 == number5 }
    }
  }

  return mutableEntry
}

let values = zip(testData,result).map { entry, result in
  entry.outputValue.map { outputValue -> Int in
    let some = result.filter { _, value in
      CharacterSet(charactersIn: value[0]) == CharacterSet(charactersIn: outputValue)
    }
    return some.reduce(0, {x,y in y.key})
  }
  .compactMap(String.init)
  .reduce("", +)
}
.compactMap { Int($0) }

let valuesSum = values.reduce(0, +)

print("Sum of all output values (part two): \(valuesSum)")

