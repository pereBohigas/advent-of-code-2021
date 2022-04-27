// --- Day 9: Smoke Basin ---
// These caves seem to be lava tubes. Parts are even still volcanically active; small hydrothermal vents release smoke into the caves that slowly settles like rain.
//
// If you can model how the smoke flows through the caves, you might be able to avoid it and be that much safer. The submarine generates a heightmap of the floor of the nearby caves for you (your puzzle input).
//
// Smoke flows to the lowest point of the area it's in. For example, consider the following heightmap:
//
// 2199943210
// 3987894921
// 9856789892
// 8767896789
// 9899965678
//
// Each number corresponds to the height of a particular location, where 9 is the highest and 0 is the lowest a location can be.
//
// Your first goal is to find the low points - the locations that are lower than any of its adjacent locations. Most locations have four adjacent locations (up, down, left, and right); locations on the edge or corner of the map have three or two adjacent locations, respectively. (Diagonal locations do not count as adjacent.)
//
// In the above example, there are four low points, all highlighted: two are in the first row (a 1 and a 0), one is in the third row (a 5), and one is in the bottom row (also a 5). All other locations on the heightmap have some lower adjacent location, and so are not low points.
//
// The risk level of a low point is 1 plus its height. In the above example, the risk levels of the low points are 2, 1, 6, and 6. The sum of the risk levels of all low points in the heightmap is therefore 15.
//
// Find all of the low points on your heightmap. What is the sum of the risk levels of all low points on your heightmap?
//
// from: https://adventofcode.com/2021/day/9

// Input:

import Foundation

let inputFileName = #filePath.replacingOccurrences(of: ".swift", with: "_input.txt")

let input = try! String(contentsOfFile: inputFileName)

let areaPoints = input.split(separator: "\n")
  .map {
    $0.compactMap { Int("\($0)") }
  }

// from: https://adventofcode.com/2021/day/9/input

// Solution Part One:

let horizontalLowPointsIndices = areaPoints.map { pointsLine in
  (0...(pointsLine.count - 1)).filter { index in
    switch (pointsLine.indices.contains(index - 1), pointsLine.indices.contains(index + 1)) {
    case (true, true):
      return pointsLine[index] < pointsLine[index - 1] && pointsLine[index] < pointsLine[index + 1]
    case (false, true):
      return pointsLine[index] < pointsLine[index + 1]
    case (true, false):
      return pointsLine[index] < pointsLine[index - 1]
    default:
      return false
    }
  }
}

let verticalLowPointsIndices = (0...(areaPoints.count - 1)).map { lineIndex in
  (0...(areaPoints[0].count - 1)).filter { columnIndex in
    switch (areaPoints.indices.contains(lineIndex - 1), areaPoints.indices.contains(lineIndex + 1)) {
    case (true, true):
      return areaPoints[lineIndex][columnIndex] < areaPoints[lineIndex - 1][columnIndex] && areaPoints[lineIndex][columnIndex] < areaPoints[lineIndex + 1][columnIndex]
    case (false, true):
      return areaPoints[lineIndex][columnIndex] < areaPoints[lineIndex + 1][columnIndex]
    case (true, false):
      return areaPoints[lineIndex][columnIndex] < areaPoints[lineIndex - 1][columnIndex]
    default:
      return false
    }
  }
}

let lowPointsIndices2 = Array(zip(horizontalLowPointsIndices, verticalLowPointsIndices)).map { horizontalIndices, verticalIndices in
  horizontalIndices.filter { verticalIndices.contains($0) }
}

// let lowPointsIndices = horizontalLowPointsIndices.enumerated().map { index, indicesLine in
//   indicesLine.filter { verticalLowPointsIndices[index].contains($0) }
// }

let riskLevels = zip(areaPoints, lowPointsIndices2).map { pointsLine, indices in
  indices.map { pointsLine[$0] + 1 }.reduce(0, +)
}

let sumOfRiskLevels = riskLevels.reduce(0, +)

print("Sum of the risk levels of all low points in the heightmap (part one): \(sumOfRiskLevels)")

// 562
