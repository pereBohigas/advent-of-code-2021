//--- Day 2: Dive! ---
//
// Now, you need to figure out how to pilot this thing.
//
// It seems like the submarine can take a series of commands like forward 1, down 2, or up 3:
//
//   - forward X increases the horizontal position by X units.
//   - down X increases the depth by X units.
//   - up X decreases the depth by X units.
//
// Note that since you're on a submarine, down and up affect your depth, and so they have the opposite result of what you might expect.
//
// The submarine seems to already have a planned course (your puzzle input). You should probably figure out where it's going. For example:
//
// forward 5
// down 5
// forward 8
// up 3
// down 8
// forward 2
//
// Your horizontal position and depth both start at 0. The steps above would then modify them as follows:
//
//   - forward 5 adds 5 to your horizontal position, a total of 5.
//   - down 5 adds 5 to your depth, resulting in a value of 5.
//   - forward 8 adds 8 to your horizontal position, a total of 13.
//   - up 3 decreases your depth by 3, resulting in a value of 2.
//   - down 8 adds 8 to your depth, resulting in a value of 10.
//   - forward 2 adds 2 to your horizontal position, a total of 15.
//
// After following these instructions, you would have a horizontal position of 15 and a depth of 10. (Multiplying these together produces 150.)
//
// Calculate the horizontal position and depth you would have after following the planned course. What do you get if you multiply your final horizontal position by your final depth?
//
// To begin, get your puzzle input.

// from: https://adventofcode.com/2021/day/2

// Input:

import Foundation

let input = try! String(contentsOfFile: "Day_2_Dive_input.txt")

let commands = input.split(separator: "\n")
   .map { $0.split(separator: " ").map(String.init) }
   .map { (command: $0[0], value: Int($0[1])!) }

// from: https://adventofcode.com/2021/day/2/input

// Solution Part One:

let horizontalPosition1: Int = commands
   .filter { $0.command == "forward" }
   .compactMap { Int($0.value) }
   .reduce(0, +)

print("Horizontal position (part one): \(horizontalPosition1)")

let depth1 = commands
   .filter { ["down", "up"].contains($0.command) }
   .map {
     if $0.command == "down" {
       return $0.value
     } else {
       return 0 - $0.value
     }
   }
   .reduce(0, +)

print("Depth (part one): \(depth1)")

print("Answer (part one): \(horizontalPosition1 * depth1)")

// --- Part Two ---
//
// Based on your calculations, the planned course doesn't seem to make any sense. You find the submarine manual and discover that the process is actually slightly more complicated.
//
// In addition to horizontal position and depth, you'll also need to track a third value, aim, which also starts at 0. The commands also mean something entirely different than you first thought:
//
//   - down X increases your aim by X units.
//   - up X decreases your aim by X units.
//   - forward X does two things:
//       - It increases your horizontal position by X units.
//       - It increases your depth by your aim multiplied by X.
//
// Again note that since you're on a submarine, down and up do the opposite of what you might expect: "down" means aiming in the positive direction.
//
// Now, the above example does something different:
//
//   - forward 5 adds 5 to your horizontal position, a total of 5. Because your aim is 0, your depth does not change.
//   - down 5 adds 5 to your aim, resulting in a value of 5.
//   - forward 8 adds 8 to your horizontal position, a total of 13. Because your aim is 5, your depth increases by 8*5=40.
//   - up 3 decreases your aim by 3, resulting in a value of 2.
//   - down 8 adds 8 to your aim, resulting in a value of 10.
//   - forward 2 adds 2 to your horizontal position, a total of 15. Because your aim is 10, your depth increases by 2*10=20 to a total of 60.
//
// After following these new instructions, you would have a horizontal position of 15 and a depth of 60. (Multiplying these produces 900.)
//
// Using this new interpretation of the commands, calculate the horizontal position and depth you would have after following the planned course. What do you get if you multiply your final horizontal position by your final depth?
//
// from: https://adventofcode.com/2021/day/2#part2

// Solution Part Two:

let horizontalPosition2: Int = commands
  .filter { $0.command == "forward" }
  .map { $0.value }
  .reduce(0, +)

print("Horizontal position (part two): \(horizontalPosition2)")

let aim: [Int] = commands
  .map {
    if $0.command == "up" {
      return 0 - $0.value
    } else if $0.command == "down" {
      return $0.value
    }
    return 0
  }

let depth2: Int = commands.enumerated()
  .map { (index,element) -> Int in
    if element.command == "forward" {
      let currentAim = aim[0...index].reduce(0, +)
      return currentAim * element.value
    }
    return 0
  }
  .reduce(0, +)

print("Depth (part two): \(depth2)")

print("Answer (part two): \(depth2 * horizontalPosition2)")

