// --- Day 15: Chiton ---
//
// You've almost reached the exit of the cave, but the walls are getting closer together. Your submarine can barely still fit, though; the main problem is that the walls of the cave are covered in chitons, and it would be best not to bump any of them.
//
// The cavern is large, but has a very low ceiling, restricting your motion to two dimensions. The shape of the cavern resembles a square; a quick scan of chiton density produces a map of risk level throughout the cave (your puzzle input). For example:
//
// 1163751742
// 1381373672
// 2136511328
// 3694931569
// 7463417111
// 1319128137
// 1359912421
// 3125421639
// 1293138521
// 2311944581
//
// You start in the top left position, your destination is the bottom right position, and you cannot move diagonally. The number at each position is its risk level; to determine the total risk of an entire path, add up the risk levels of each position you enter (that is, don't count the risk level of your starting position unless you enter it; leaving it adds no risk to your total).
//
// Your goal is to find a path with the lowest total risk. In this example, a path with the lowest total risk is highlighted here:
//
// 1163751742
// 1381373672
// 2136511328
// 3694931569
// 7463417111
// 1319128137
// 1359912421
// 3125421639
// 1293138521
// 2311944581
//
// The total risk of this path is 40 (the starting position is never entered, so its risk is not counted).
//
// What is the lowest total risk of any path from the top left to the bottom right?
//
// from: https://adventofcode.com/2021/day/15

// Input:

import Foundation

let inputFileName = #filePath.replacingOccurrences(of: ".swift", with: "_input.txt")

let input = try! String(contentsOfFile: inputFileName)

let riskLevelmap = input.split(separator: "\n")
  .map {
    $0.compactMap { Int("\($0)") }
  }

let initialPositionIndices = (x: 0, y: 0)

let finalPositionIndices = { (map: [[Int]]) -> (Int, Int) in
  let maxYIndex = map.count - 1

  return (maxYIndex, map[maxYIndex].count - 1)
}

// from: https://adventofcode.com/2021/day/15/input

// Test data:

let testData = [
    "1163751742",
    "1381373672",
    "2136511328",
    "3694931569",
    "7463417111",
    "1319128137",
    "1359912421",
    "3125421639",
    "1293138521",
    "2311944581"
  ].map {
    $0.compactMap { Int("\($0)") }
  }

// Solution Part One:

print(testData)

typealias Position = (x: Int, y: Int, riskLevel: Int)

let nextHorizontalPosition = { (current: Position, riskLevels: [[Int]]) -> Position in
  let newX = (riskLevels[current.y].count - 1) > current.x ? current.x + 1 : current.x

  return (newX, current.y, riskLevels[current.y][newX])
}

let nextVerticalPosition = { (current: Position, riskLevels: [[Int]]) -> Position in
  let newY = (riskLevels.count - 1) > current.y ? current.y + 1 : current.y

  return (current.x, newY, riskLevels[newY][current.x])
}

let finalPosition = finalPositionIndices(testData)

let initialIndices = initialPositionIndices
var route = [Position]()

print("final: \(finalPositionIndices(testData))")
print("from: \(currentPosition)")

while currentPosition != finalPosition {
  let horizontalCandidate = nextHorizontalPosition(route.last!, testData)
  let verticalCandidate = nextVerticalPosition(route.last!, testData)

  let nextPosition: Position
  if horizontalCandidate.riskLevel < verticalCandidate.riskLevel {
    nextPosition = horizontalCandidate
    route.append(nextPosition)
  } else {
    nextPosition = verticalCandidate
    route.append(nextPosition)
  }

  let nextRiskLevel = horizontalCandidate.riskLevel < verticalCandidate.riskLevel
    ? horizontalCandidate.riskLevel
    : verticalCandidate.riskLevel

  print("between \(horizontalCandidate) and \(verticalCandidate) moved to: \(nextRiskLevel) on \(currentPosition)")
}


