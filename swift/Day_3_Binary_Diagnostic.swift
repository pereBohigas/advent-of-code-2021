// --- Day 3: Binary Diagnostic ---
//
// The submarine has been making some odd creaking noises, so you ask it to produce a diagnostic report just in case.
//
// The diagnostic report (your puzzle input) consists of a list of binary numbers which, when decoded properly, can tell you many useful things about the conditions of the submarine. The first parameter to check is the power consumption.
//
// You need to use the binary numbers in the diagnostic report to generate two new binary numbers (called the gamma rate and the epsilon rate). The power consumption can then be found by multiplying the gamma rate by the epsilon rate.
//
// Each bit in the gamma rate can be determined by finding the most common bit in the corresponding position of all numbers in the diagnostic report. For example, given the following diagnostic report:
//
// 00100
// 11110
// 10110
// 10111
// 10101
// 01111
// 00111
// 11100
// 10000
// 11001
// 00010
// 01010
//
// Considering only the first bit of each number, there are five 0 bits and seven 1 bits. Since the most common bit is 1, the first bit of the gamma rate is 1.
//
// The most common second bit of the numbers in the diagnostic report is 0, so the second bit of the gamma rate is 0.
//
// The most common value of the third, fourth, and fifth bits are 1, 1, and 0, respectively, and so the final three bits of the gamma rate are 110.
//
// So, the gamma rate is the binary number 10110, or 22 in decimal.
//
// The epsilon rate is calculated in a similar way; rather than use the most common bit, the least common bit from each position is used. So, the epsilon rate is 01001, or 9 in decimal. Multiplying the gamma rate (22) by the epsilon rate (9) produces the power consumption, 198.
//
// Use the binary numbers in your diagnostic report to calculate the gamma rate and epsilon rate, then multiply them together. What is the power consumption of the submarine? (Be sure to represent your answer in decimal, not binary.)
//
// from: https://adventofcode.com/2021/day/3

// Input:

import Foundation

let inputFileName = #filePath.replacingOccurrences(of: ".swift", with: "_input.txt")

let input = try! String(contentsOfFile: inputFileName)

let diagnosticReport = input.split(separator: "\n").map(String.init)

let binaryNumberIndices = diagnosticReport[0].indices

// from: https://adventofcode.com/2021/day/3/input

let testData = [
    "00100",
    "11110",
    "10110",
    "10111",
    "10101",
    "01111",
    "00111",
    "11100",
    "10000",
    "11001",
    "00010",
    "01010"
  ]

// Solution Part One:

let bitFrequencies: [[Character: Int]] = binaryNumberIndices
  .map { digitIndex in
    let digitArray = diagnosticReport
      .map { ($0[digitIndex], 1) }

    return Dictionary(digitArray, uniquingKeysWith: +)
  }

let gammaRate: String = bitFrequencies
  .compactMap { $0.max() { $0.value < $1.value } }
  .map { String($0.key) }
  .joined()

print("Gamma rate (part one): \(gammaRate)")

let epsilonRate: String = bitFrequencies
  .compactMap { $0.min { $0.value < $1.value } }
  .map { String($0.key) }
  .joined()

print("Epsilon rate (part one): \(epsilonRate)")

let powerConsumption: Int = [gammaRate, epsilonRate]
  .compactMap { Int($0, radix: 2) }
  .reduce(1, *)

print("Answer (part one) - Power consumption: \(powerConsumption)")

// --- Part Two ---
//
// Next, you should verify the life support rating, which can be determined by multiplying the oxygen generator rating by the CO2 scrubber rating.
//
// Both the oxygen generator rating and the CO2 scrubber rating are values that can be found in your diagnostic report - finding them is the tricky part. Both values are located using a similar process that involves filtering out values until only one remains. Before searching for either rating value, start with the full list of binary numbers from your diagnostic report and consider just the first bit of those numbers. Then:
//
//   - Keep only numbers selected by the bit criteria for the type of rating value for which you are searching. Discard numbers which do not match the bit criteria.
//   - If you only have one number left, stop; this is the rating value for which you are searching.
//   - Otherwise, repeat the process, considering the next bit to the right.
//
// The bit criteria depends on which type of rating value you want to find:
//
//   - To find oxygen generator rating, determine the most common value (0 or 1) in the current bit position, and keep only numbers with that bit in that position. If 0 and 1 are equally common, keep values with a 1 in the position being considered.
//   - To find CO2 scrubber rating, determine the least common value (0 or 1) in the current bit position, and keep only numbers with that bit in that position. If 0 and 1 are equally common, keep values with a 0 in the position being considered.
//
// For example, to determine the oxygen generator rating value using the same example diagnostic report from above:
//
//   - Start with all 12 numbers and consider only the first bit of each number. There are more 1 bits (7) than 0 bits (5), so keep only the 7 numbers with a 1 in the first position: 11110, 10110, 10111, 10101, 11100, 10000, and 11001.
//   - Then, consider the second bit of the 7 remaining numbers: there are more 0 bits (4) than 1 bits (3), so keep only the 4 numbers with a 0 in the second position: 10110, 10111, 10101, and 10000.
//   - In the third position, three of the four numbers have a 1, so keep those three: 10110, 10111, and 10101.
//   -  In the fourth position, two of the three numbers have a 1, so keep those two: 10110 and 10111.
//   - In the fifth position, there are an equal number of 0 bits and 1 bits (one each). So, to find the oxygen generator rating, keep the number with a 1 in that position: 10111.
//   - As there is only one number left, stop; the oxygen generator rating is 10111, or 23 in decimal.
//
// Then, to determine the CO2 scrubber rating value from the same example above:
//
//   - Start again with all 12 numbers and consider only the first bit of each number. There are fewer 0 bits (5) than 1 bits (7), so keep only the 5 numbers with a 0 in the first position: 00100, 01111, 00111, 00010, and 01010.
//   - Then, consider the second bit of the 5 remaining numbers: there are fewer 1 bits (2) than 0 bits (3), so keep only the 2 numbers with a 1 in the second position: 01111 and 01010.
//   - In the third position, there are an equal number of 0 bits and 1 bits (one each). So, to find the CO2 scrubber rating, keep the number with a 0 in that position: 01010.
//   - As there is only one number left, stop; the CO2 scrubber rating is 01010, or 10 in decimal.
//
// Finally, to find the life support rating, multiply the oxygen generator rating (23) by the CO2 scrubber rating (10) to get 230.
//
// Use the binary numbers in your diagnostic report to calculate the oxygen generator rating and CO2 scrubber rating, then multiply them together. What is the life support rating of the submarine? (Be sure to represent your answer in decimal, not binary.)
//
// from: https://adventofcode.com/2021/day/3#part2

// Solution Part Two:

let mostCommonBit = { (frequencies: [Character: Int]) -> Character in
    frequencies.max() {
        $0.value != $1.value ? $0.value < $1.value : $1.key == "1"
    }!.key
  }

let leastCommonBit = { (frequencies: [Character: Int]) -> Character in
    frequencies.min() {
        $0.value != $1.value ? $0.value < $1.value : $0.key == "0"
    }!.key
  }

var oxygenGeneratorRatingCandidates = diagnosticReport

var positions = binaryNumberIndices

while(oxygenGeneratorRatingCandidates.count > 1 && positions.count > 0) {
  guard let position = positions.first else { continue }

  let bitFrequenciesForPosition = oxygenGeneratorRatingCandidates.map {
      ($0[position], 1)
    }

  let mostCommonBitForPosition = mostCommonBit(
      Dictionary(bitFrequenciesForPosition, uniquingKeysWith: +)
    )

  oxygenGeneratorRatingCandidates = oxygenGeneratorRatingCandidates.filter {
      $0[position] == mostCommonBitForPosition
    }

  positions = positions.dropFirst()
}

let oxygenGeneratorRating = Int(oxygenGeneratorRatingCandidates.first!, radix: 2)!

print("Oxygen generator rating (part two): \(oxygenGeneratorRating)")

var co2ScrubberRatingCandidates = diagnosticReport

positions = binaryNumberIndices

while(co2ScrubberRatingCandidates.count > 1 && positions.count > 0) {
  guard let position = positions.first else { continue }

  let bitFrequenciesForPosition = co2ScrubberRatingCandidates.map {
      ($0[position], 1)
    }

  let leastCommonBitForPosition = leastCommonBit(
      Dictionary(bitFrequenciesForPosition, uniquingKeysWith: +)
    )

  co2ScrubberRatingCandidates = co2ScrubberRatingCandidates.filter {
      $0[position] == leastCommonBitForPosition
    }

  positions = positions.dropFirst()
}

let co2ScrubberRating = Int(co2ScrubberRatingCandidates.first!, radix: 2)!

print("CO2 scrubber rating (part two): \(co2ScrubberRating)")

let lifeSupportRating = oxygenGeneratorRating * co2ScrubberRating

print("Answer (part two) - Life support rating: \(lifeSupportRating)")

