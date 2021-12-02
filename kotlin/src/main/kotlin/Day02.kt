/*
--- Day 2: Dive! ---
Now, you need to figure out how to pilot this thing.

It seems like the submarine can take a series of commands like forward 1, down 2, or up 3:

forward X increases the horizontal position by X units.
down X increases the depth by X units.
up X decreases the depth by X units.
Note that since you're on a submarine, down and up affect your depth, and so they have the opposite result of what you might expect.

The submarine seems to already have a planned course (your puzzle input). You should probably figure out where it's going. For example:

forward 5
down 5
forward 8
up 3
down 8
forward 2
Your horizontal position and depth both start at 0. The steps above would then modify them as follows:

forward 5 adds 5 to your horizontal position, a total of 5.
down 5 adds 5 to your depth, resulting in a value of 5.
forward 8 adds 8 to your horizontal position, a total of 13.
up 3 decreases your depth by 3, resulting in a value of 2.
down 8 adds 8 to your depth, resulting in a value of 10.
forward 2 adds 2 to your horizontal position, a total of 15.
After following these instructions, you would have a horizontal position of 15 and a depth of 10. (Multiplying these together produces 150.)

Calculate the horizontal position and depth you would have after following the planned course. What do you get if you multiply your final horizontal position by your final depth?
*/

/*
--- Part Two ---
Based on your calculations, the planned course doesn't seem to make any sense. You find the submarine manual and discover that the process is actually slightly more complicated.

In addition to horizontal position and depth, you'll also need to track a third value, aim, which also starts at 0. The commands also mean something entirely different than you first thought:

down X increases your aim by X units.
up X decreases your aim by X units.
forward X does two things:
It increases your horizontal position by X units.
It increases your depth by your aim multiplied by X.
Again note that since you're on a submarine, down and up do the opposite of what you might expect: "down" means aiming in the positive direction.

Now, the above example does something different:

forward 5 adds 5 to your horizontal position, a total of 5. Because your aim is 0, your depth does not change.
down 5 adds 5 to your aim, resulting in a value of 5.
forward 8 adds 8 to your horizontal position, a total of 13. Because your aim is 5, your depth increases by 8*5=40.
up 3 decreases your aim by 3, resulting in a value of 2.
down 8 adds 8 to your aim, resulting in a value of 10.
forward 2 adds 2 to your horizontal position, a total of 15. Because your aim is 10, your depth increases by 2*10=20 to a total of 60.
After following these new instructions, you would have a horizontal position of 15 and a depth of 60. (Multiplying these produces 900.)

Using this new interpretation of the commands, calculate the horizontal position and depth you would have after following the planned course. What do you get if you multiply your final horizontal position by your final depth?
 */

// From: https://adventofcode.com/2021/day/2

object Day02 {

    private const val inputTxt = "input02.txt"

    /* read input from file */
    private val inputString: String? = javaClass.getResource(inputTxt)?.readText()

    /* convert the input string to a list if direction Strings representing each line, omitting black lines */
    private val directionStrings: List<DirectionString>? = inputString?.lines()
        ?.mapNotNull { when {
            it.isBlank() -> null
            else -> it.toDirectionString()
        }}

    private fun String.toDirectionString(): DirectionString? = when {
        matches(Direction.FORWARD.getRegex()) -> DirectionString(this, Direction.FORWARD)
        matches(Direction.DOWN.getRegex()) -> DirectionString(this, Direction.DOWN)
        matches(Direction.UP.getRegex()) -> DirectionString(this, Direction.UP)
        else -> null
    }

    fun partOne(): Int? {

        directionStrings ?: return null

        val horizontal = directionStrings
            .filter { it.direction == Direction.FORWARD }
            .sumOf { it.value }

        val downSum = directionStrings
            .filter { it.direction == Direction.DOWN }
            .sumOf { it.value }

        val upSum = directionStrings
            .filter { it.direction == Direction.UP }
            .sumOf { it.value }

        val depth = downSum - upSum

        return depth * horizontal

    }

    fun partTwo(): Int? {

        directionStrings ?: return null

        /* Specify the initial position (0, 0, 0) */
        val initialPosition = Position(
            horizontal = 0,
            depth = 0,
            aim = 0
        )

        /*
            Specify what to do, i.e. calculate the next position from the current position and the direction

             "operation" is a function:
               => fn (current position, direction) -> next position
         */
        val operation = { currentPosition: Position, (direction, X): DirectionString ->
            when (direction) {
                /* If direction says forward, increase horizontal by X, and depth by aim * X */
                Direction.FORWARD -> Position(
                    currentPosition.horizontal + X,
                    currentPosition.depth + (currentPosition.aim * X),
                    currentPosition.aim
                )
                /* If direction says down, increase aim by X */
                Direction.DOWN -> Position(
                    currentPosition.horizontal,
                    currentPosition.depth,
                    currentPosition.aim + X
                )
                /* If direction says down, decrease aim by X */
                Direction.UP -> Position(
                    currentPosition.horizontal,
                    currentPosition.depth,
                    currentPosition.aim - X
                )
            }
        }

        /* Apply (operation) to each item in directionStrings, accumulating from left to right. */
        val endPosition = directionStrings.fold(initialPosition, operation)   // GO KOTLIN COLLECTIONS!!

        return endPosition.multiplyHorizontalAndDepth()
    }

}

enum class Direction(val str: String) {
    FORWARD("forward"), DOWN("down"), UP("up");

    fun getRegex(): Regex = "($str)( )(\\d*)".toRegex()
}

class DirectionString(input: String, val direction: Direction) {

    val value: Int = input
        .replace(direction.str, "")
        .replace(" ", "")
        .toInt()

    operator fun component1(): Direction = direction

    operator fun component2(): Int = value

    override fun toString(): String = "${component1()} ${component2()}"

}

data class Position(val horizontal: Int, val depth: Int, val aim: Int) {

    fun multiplyHorizontalAndDepth(): Int = horizontal * depth

}

fun main() {
    println(Day02.partOne())
    println("---")
    println()
    println(Day02.partTwo())
}
