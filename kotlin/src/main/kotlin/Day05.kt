import kotlin.math.abs

/*
--- Day 5: Hydrothermal Venture ---

You come across a field of hydrothermal vents on the ocean floor! These vents constantly produce large, opaque clouds, so it would be best to avoid them if possible.

They tend to form in lines; the submarine helpfully produces a list of nearby lines of vents (your puzzle input) for you to review. For example:

0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2

Each line of vents is given as a line segment in the format x1,y1 -> x2,y2 where x1,y1 are the coordinates of one end the line segment and x2,y2 are the coordinates of the other end. These line segments include the points at both ends. In other words:

    An entry like 1,1 -> 1,3 covers points 1,1, 1,2, and 1,3.
    An entry like 9,7 -> 7,7 covers points 9,7, 8,7, and 7,7.

For now, only consider horizontal and vertical lines: lines where either x1 = x2 or y1 = y2.

So, the horizontal and vertical lines from the above list would produce the following diagram:

.......1..
..1....1..
..1....1..
.......1..
.112111211
..........
..........
..........
..........
222111....

In this diagram, the top left corner is 0,0 and the bottom right corner is 9,9. Each position is shown as the number of lines which cover that point or . if no line covers that point. The top-left pair of 1s, for example, comes from 2,2 -> 2,1; the very bottom row is formed by the overlapping lines 0,9 -> 5,9 and 0,9 -> 2,9.

To avoid the most dangerous areas, you need to determine the number of points where at least two lines overlap. In the above example, this is anywhere in the diagram with a 2 or larger - a total of 5 points.

Consider only horizontal and vertical lines. At how many points do at least two lines overlap?
 */

/*
--- Part Two ---

Unfortunately, considering only horizontal and vertical lines doesn't give you the full picture; you need to also consider diagonal lines.

Because of the limits of the hydrothermal vent mapping system, the lines in your list will only ever be horizontal, vertical, or a diagonal line at exactly 45 degrees. In other words:

    An entry like 1,1 -> 3,3 covers points 1,1, 2,2, and 3,3.
    An entry like 9,7 -> 7,9 covers points 9,7, 8,8, and 7,9.

Considering all lines from the above example would now produce the following diagram:

1.1....11.
.111...2..
..2.1.111.
...1.2.2..
.112313211
...1.2....
..1...1...
.1.....1..
1.......1.
222111....

You still need to determine the number of points where at least two lines overlap. In the above example, this is still anywhere in the diagram with a 2 or larger - now a total of 12 points.

Consider all of the lines. At how many points do at least two lines overlap?
 */

// From: https://adventofcode.com/2021/day/5

object Day05 {

    private const val inputTxt = "input05.txt"

    private const val plotSize = 1000

    /* read input from file */
    private val inputString: String? = javaClass.getResource(inputTxt)?.readText()

    /* convert the input to a list of Lines */
    private val lines: List<Line>? = inputString?.lines()?.filterNotBlank()?.map { Line.from(it) }

    fun partOne(): Int? {

        lines ?: return null

        val plot = Plot(plotSize)

        lines.forEach {
            plot.addLine(it)
        }

        return plot.countOverlaps()

    }

    fun partTwo(): Int? {

        lines ?: return null

        val plot = Plot(plotSize)

        lines.forEach {
            plot.addLineDiagonal(it)
        }

        return plot.countOverlaps()

    }

}

class Plot(size: Int) {

    private val canvas = MutableList(size) { MutableList(size) { 0 } }

    private fun setPoint(point: Line.Point) {
        canvas[point.x][point.y] += 1
    }

    fun addLine(line: Line) {
        line.getPoints().forEach { setPoint(it) }
    }

    fun addLineDiagonal(line: Line) {
        line.getPointsWithDiagonal().forEach { setPoint(it) }
    }

    fun countOverlaps(): Int {
        return canvas.flatten().count { it > 1 }
    }

}

class Line(private val p1: Point, private val p2: Point) {

    /* Horizontal/Vertical/Diagonal Checking */
    private fun isHorizontal(): Boolean = p1.y == p2.y
    private fun isVertical(): Boolean = p1.x == p2.x
    private fun isDiagonal(): Boolean = abs(p1.x - p2.x) == abs(p1.y - p2.y)

    private fun getYProgression(): IntProgression = when {
        p1.y > p2.y -> p1.y downTo p2.y
        else -> p1.y..p2.y
    }
    private fun getXProgression(): IntProgression = when {
        p1.x > p2.x -> p1.x downTo p2.x
        else -> p1.x..p2.x
    }

    /* Get all points on that line (calculation only valid for horizontal or vertical lines) */
    fun getPoints(): List<Point> = when {
        isHorizontal() -> getXProgression().map { Point(it, p1.y) }
        isVertical() -> getYProgression().map { Point(p1.x, it) }
        else -> emptyList()
    }

    /* Get all points on that line (with diagonal lines) */
    fun getPointsWithDiagonal(): List<Point> = when {
        isHorizontal() -> getXProgression().map { Point(it, p1.y) }
        isVertical() -> getYProgression().map { Point(p1.x, it) }
        isDiagonal() -> getXProgression().zip(getYProgression()).map(Point::from)
        else -> emptyList()
    }

    data class Point(val x: Int, val y: Int) {

        override fun toString(): String = "($x, $y)"

        companion object {

            fun from(input: String): Point =
                from(input.split(",")
                    .map(String::toInt)
                    .zipWithNext()
                    .single())

            fun from(pair: Pair<Int, Int>): Point = Point(pair.first, pair.second)

        }

    }

    override fun toString(): String = "$p1 -> $p2"

    companion object {

        fun from(input: String): Line {
            val (p1, p2) = input.split("->").map { Point.from(it.trim()) }
            return Line(p1, p2)
        }

    }

}

fun main() {
    println(Day05.partOne())
    println("---")
    println()
    println(Day05.partTwo())
}
