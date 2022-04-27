// --- Day 12: Passage Pathing ---
//
// With your submarine's subterranean subsystems subsisting suboptimally, the only way you're getting out of this cave anytime soon is by finding a path yourself. Not just a path - the only way to know if you've found the best path is to find all of them.
//
// Fortunately, the sensors are still mostly working, and so you build a rough map of the remaining caves (your puzzle input). For example:
//
// start-A
// start-b
// A-c
// A-b
// b-d
// A-end
// b-end
//
// This is a list of how all of the caves are connected. You start in the cave named start, and your destination is the cave named end. An entry like b-d means that cave b is connected to cave d - that is, you can move between them.
//
// So, the above cave system looks roughly like this:
//
//     start
//     /   \
// c--A-----b--d
//     \   /
//     end
//
// Your goal is to find the number of distinct paths that start at start, end at end, and don't visit small caves more than once. There are two types of caves: big caves (written in uppercase, like A) and small caves (written in lowercase, like b). It would be a waste of time to visit any small cave more than once, but big caves are large enough that it might be worth visiting them multiple times. So, all paths you find should visit small caves at most once, and can visit big caves any number of times.
//
// Given these rules, there are 10 paths through this example cave system:
//
// start,A,b,A,c,A,end
// start,A,b,A,end
// start,A,b,end
// start,A,c,A,b,A,end
// start,A,c,A,b,end
// start,A,c,A,end
// start,A,end
// start,b,A,c,A,end
// start,b,A,end
// start,b,end
//
// (Each line in the above list corresponds to a single path; the caves visited by that path are listed in the order they are visited and separated by commas.)
//
// Note that in this cave system, cave d is never visited by any path: to do so, cave b would need to be visited twice (once on the way to cave d and a second time when returning from cave d), and since cave b is small, this is not allowed.
//
// Here is a slightly larger example:
//
// dc-end
// HN-start
// start-kj
// dc-start
// dc-HN
// LN-dc
// HN-end
// kj-sa
// kj-HN
// kj-dc
//
// The 19 paths through it are as follows:
//
// start,HN,dc,HN,end
// start,HN,dc,HN,kj,HN,end
// start,HN,dc,end
// start,HN,dc,kj,HN,end
// start,HN,end
// start,HN,kj,HN,dc,HN,end
// start,HN,kj,HN,dc,end
// start,HN,kj,HN,end
// start,HN,kj,dc,HN,end
// start,HN,kj,dc,end
// start,dc,HN,end
// start,dc,HN,kj,HN,end
// start,dc,end
// start,dc,kj,HN,end
// start,kj,HN,dc,HN,end
// start,kj,HN,dc,end
// start,kj,HN,end
// start,kj,dc,HN,end
// start,kj,dc,end
//
// Finally, this even larger example has 226 paths through it:
//
// fs-end
// he-DX
// fs-he
// start-DX
// pj-DX
// end-zg
// zg-sl
// zg-pj
// pj-he
// RW-he
// fs-DX
// pj-RW
// zg-RW
// start-pj
// he-WI
// zg-he
// pj-fs
// start-RW
//
// How many paths through this cave system are there that visit small caves at most once?
//
// from: https://adventofcode.com/2021/day/12

// Input:

import Foundation

let inputFileName = #filePath.replacingOccurrences(of: ".swift", with: "_input.txt")

let input = try! String(contentsOfFile: inputFileName)

typealias CaveConnection = (String, String)

let cavesSystem: [CaveConnection] = input.split(separator: "\n")
  .map {
    $0.split(separator: "-").compactMap(String.init)
  }
  .map {
    ($0[0], $0[1])
  }

// from: https://adventofcode.com/2021/day/9/input

// Test data:

let testData = [
    "start-A",
    "start-b",
    "A-c",
    "A-b",
    "b-d",
    "A-end",
    "b-end"
  ].map {
    $0.split(separator: "-").compactMap(String.init)
  }
  .map {
    ($0[0], $0[1])
  }

// Solution Part One:

let caves = testData

extension String {
  var isLowercase: Bool {
    CharacterSet(charactersIn: self).isSubset(of: CharacterSet.lowercaseLetters)
  }
}

// small caves only once

print(caves)

let initialCaveConnections = caves.filter { $0.0 == "start" || $0.1 == "start" }

let nonInitialCaveConnections = caves.filter { $0.0 != "start" || $0.1 == "start" }

var paths: [[String]] = [[String]]()

let getNextConnections = { (previousCave: String, connections: [CaveConnection]) -> [CaveConnection] in
  connections.filter { connection in
    previousCave = connection.0 || previousCave = connection.1
  }
}

let getPath = { (currentPath: [CaveConnection], availableConnections: [CaveConnection], visitedPaths: [[CaveConnection]]) -> [CaveConnection] in
  let commonPaths = visitedPaths.filter { visitedPath in
    if visitedPath.count > currentPath.count {
      currentPath.enumerated().filter { index, connection in
        visitedPath[index] == connection
      }.count == 0
    }

    return false
  }

  let tokenConnections = commonPaths.map { $0[currentPath + 1] }

  let nextConnection = availableConnections.filter({ !tokenConnections.contains($0) })[0]

  if let nextConnection = nextConnection {
    if (nextConnection.0 != "end" || nextConnection.1 != "end") {
      let newCurrentPath = currentPath.append[nextConnection]
      getPath(newCurrentPath, availableConnections, visitedPaths)
    } if else (nextConnection.0 == "end" || nextConnection.1 == "end") {
      let newVisitedPaths = visitedPaths.append(currentPath)
      getPath([CaveConnection](), availableConnections, newVisitedPaths)
    }
  } else {
    let newVisitedPaths = visitedPaths.append(currentPath)
    getPath([CaveConnection](), availableConnections, newVisitedPaths)
  }
}
// - path should start at "start" and end at "end"
// - small caves (lowercase) can only be visited once

initialCaveConnections.forEach { initialConnection in
  let path = [initialConnection.0, initialConnection.1]
  var availableConnections = nonInitialCaveConnections
  var nextConnection: CaveConnection? = nil

  repeat {
    var subPath = path
    let nextPossibleConnections = getNextConnections(availableConnections, subPath)

    nextPossibleConnections.forEach {

    .next { connection in
      let lhs = connection.0
      let rhs = connection.1

      if (lhs.isLowercase && path.contains(lhs)) || (rhs.isLowercase && path.contains(rhs)) {
        return
      }

      if lhs = path.last! {
        path.append(rhs)
        return
      else if rhs = path.last! {
        path.append(lhs)
        return
      }
    }
  } while(path.last! != "end")
}



// let paths = initialCaveConnections.map { initialConnection -> [[String]] in
//   let initialPath: [String] = [initialConnection.0, initialConnection.1]

//   print("Starting on \(initialConnection.0)")
//   print("-> \(initialConnection.1)")

//   var subpaths = nonInitialCaveConnections.filter { $0.0 == initialPath.last || $0.1 == initialPath.last }.map { caveConnection -> [String] in
//     var visitedSmallCaves: [String] = initialPath.last!.isLowercase ? [initialPath.last!] : [String]()

//     let nextCave: String = caveConnection.0 == initialPath.last ? caveConnection.1 : caveConnection.0

//     print("-> \(nextCave)")

//     if nextCave.isLowercase {
//       visitedSmallCaves.append(nextCave)
//     }
//     var subpath: [String] = [nextCave]

//     while (subpath.last != "end") {
//       let lastCave = subpath.last!

//       if lastCave.isLowercase {
//         visitedSmallCaves.append(lastCave)
//       }

//       for connection in nonInitialCaveConnections.filter({ visitedSmallCaves.contains($0.0) || visitedSmallCaves.contains($0.1) }) {
//         if subpath.last == connection.0 {
//           subpath.append(connection.1)
//         } else if subpath.last == connection.1 {
//           subpath.append(connection.0)
//         }
//       }
//     }

//     return subpath
//   }

//   return subpaths.map { initialPath + $0 }
// }

// print(paths)

// let paths = initialCaveConnections.map { initialCaveConnection -> [String] in
//   var result: [String] = [initialCaveConnection.0, initialCaveConnection.1]
//   var visitedSmallCaves: [String] = [String]()

//   let cleanedCaves = caves.filter { $0.0 != "start" }

//   while (result.last != "end") {
//     if let lastCave = result.last, !lastCave.isUppercase {
//       visitedSmallCaves.append(lastCave)
//     }

//     for caveConnection in cleanedCaves {
//       if result.last == caveConnection.0 && !visitedSmallCaves.contains(caveConnection.0) {
//         result.append(caveConnection.1)
//       } else if result.last == caveConnection.1 && !visitedSmallCaves.contains(caveConnection.1) {
//         result.append(caveConnection.0)
//       }
//     }

//     result.append("end")
//   }

//   print(result)
//   return result
// }





