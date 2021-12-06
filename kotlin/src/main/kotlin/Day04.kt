/*
--- Day 4: Giant Squid ---

You're already almost 1.5km (almost a mile) below the surface of the ocean, already so deep that you can't see any sunlight. What you can see, however, is a giant squid that has attached itself to the outside of your submarine.

Maybe it wants to play bingo?

Bingo is played on a set of boards each consisting of a 5x5 grid of numbers. Numbers are chosen at random, and the chosen number is marked on all boards on which it appears. (Numbers may not appear on all boards.) If all numbers in any row or any column of a board are marked, that board wins. (Diagonals don't count.)

The submarine has a bingo subsystem to help passengers (currently, you and the giant squid) pass the time. It automatically generates a random order in which to draw numbers and a random set of boards (your puzzle input). For example:

7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7

After the first five numbers are drawn (7, 4, 9, 5, and 11), there are no winners, but the boards are marked as follows (shown here adjacent to each other to save space):

22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
 8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
 6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
 1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

After the next six numbers are drawn (17, 23, 2, 0, 14, and 21), there are still no winners:

22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
 8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
 6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
 1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

Finally, 24 is drawn:

22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
 8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
 6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
 1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

At this point, the third board wins because it has at least one complete row or column of marked numbers (in this case, the entire top row is marked: 14 21 17 24 4).

The score of the winning board can now be calculated. Start by finding the sum of all unmarked numbers on that board; in this case, the sum is 188. Then, multiply that sum by the number that was just called when the board won, 24, to get the final score, 188 * 24 = 4512.

To guarantee victory against the giant squid, figure out which board will win first. What will your final score be if you choose that board?
 */

/*
--- Part Two ---

On the other hand, it might be wise to try a different strategy: let the giant squid win.

You aren't sure how many bingo boards a giant squid could play at once, so rather than waste time counting its arms, the safe thing to do is to figure out which board will win last and choose that one. That way, no matter which boards it picks, it will win for sure.

In the above example, the second board is the last to win, which happens after 13 is eventually called and its middle column is completely marked. If you were to keep playing until this point, the second board would have a sum of unmarked numbers equal to 148 for a final score of 148 * 13 = 1924.

Figure out which board will win last. Once it wins, what would its final score be?
 */

// From: https://adventofcode.com/2021/day/4

object Day04 {

    private const val inputTxt = "input04.txt"

    private const val boardSize = 5

    /* read input from file */
    private val inputString: String? = javaClass.getResource(inputTxt)?.readText()

    /* The first line of inputString is the order of numbers to mark */
    private val orderOfNumbers: List<Int>? = inputString?.lines()?.get(0)?.split(",")?.map(String::toInt)

    /* The rest of the lines are the boards */
    private val boardLines: List<String>? = inputString?.lines()?.drop(1)

    /* Take chunks of 6 lines as one board (5 "real" board lines and one empty line) */
    private val boardChunks: List<List<String>>? = boardLines?.chunked(boardSize + 1)

    /*
        For every boardChunk except the last one, try to convert it to a board.

        This means that the first line in every boardChunk should be empty.
        The other lines should be 5 numbers each.
     */
    private val boards: BoardList? = BoardList.from(boardChunks, boardSize)

    /* Define an operation that represents one bingo-move (marking one number on a list of boards) */
    private val markNumberOperation: (BoardList, Int) -> BoardList = { newBoards, number ->
        newBoards.mark(number)
    }

    fun partOne(): Int? {

        orderOfNumbers ?: return null
        boards ?: return null

        val finalBoards = orderOfNumbers.fold(boards, markNumberOperation)

        return finalBoards.getFirstComplete().score

    }

    fun partTwo(): Int? {

        orderOfNumbers ?: return null
        boards ?: return null

        val finalBoards = orderOfNumbers.fold(boards, markNumberOperation)

        return finalBoards.getLastComplete().score

    }

}

fun List<String>.filterNotBlank(): List<String> = filterNot(String::isBlank)

/*
    Immutable Board List.
    For each operation that alters one of the Boards,
    a new BoardList object with the changes is returned
 */
class BoardList(private val boards: List<Board>, oldCompletedList: List<Board> = emptyList()) {

    fun mark(number: Int): BoardList = BoardList(boards.map { it.mark(number) }, oldCompletedList=completedList)

    private val completedList =
        oldCompletedList.plus(boards.filter(Board::isComplete).filterNot(oldCompletedList::contains))

    fun getFirstComplete(): Board = when (completedList.size) {
        0 -> throw IllegalStateException("No complete boards")
        else -> completedList.first()
    }

    fun getLastComplete(): Board = when (completedList.size) {
        0 -> throw IllegalStateException("No complete boards")
        else -> completedList.last()
    }

    companion object {

        fun from(boardChunks: List<List<String>>?, size: Int): BoardList? = boardChunks?.let {
            BoardList(it.dropLast(1).map { lines -> Board.from(lines.drop(1), size) })
        }

    }
}

class Board(private val rows: List<Row>, private val size: Int, private val lastMarked: Int?) {

    private val columns: List<Column> = List(size) { index -> Column.from(rows, index) }

    /* Mark a cell as marked on the board. If the board is complete, don't alter it. */
    fun mark(number: Int): Board = when (isComplete()) {
        true -> this
        false -> Board(rows.map { it.copyWithMarked(number) }, size, number)
    }

    /* Completeness Checking */
    fun isComplete(): Boolean = hasFullRow() || hasFullColumn()

    private fun hasFullRow(): Boolean = rows.any(Row::completelyMarked)
    private fun hasFullColumn(): Boolean = columns.any(Column::completelyMarked)

    /* Score Calculation */
    val score: Int? = when (isComplete()) {
        true -> lastMarked?.let {
            lastMarked * getUnmarkedSum()
        } ?: throw IllegalStateException("Board is complete but no lastMarked found")
        false -> null
    }

    private fun getUnmarked(): List<Cell> = rows.flatMap(Row::getUnmarked)
    private fun getUnmarkedSum(): Int = getUnmarked().sumOf(Cell::number)

    override fun toString(): String {
        return rows.joinToString("\n")
    }

    class Row(private val cells: List<Cell>, private val size: Int) {

        fun get(index: Int): Cell = cells[index]

        fun copyWithMarked(number: Int): Row = Row(cells.map { it.copyWithMarked(number) }, size)

        val completelyMarked = cells.all(Cell::isMarked)

        fun getUnmarked(): List<Cell> = cells.filterNot(Cell::isMarked)

        override fun toString(): String {
            return cells.joinToString(separator = " ")
        }

        companion object {

            fun from(line: String, size: Int): Row = line.split(" ").filterNotBlank().let {
                when (it.size) {
                    size -> Row(it.map(Cell::from), size)
                    else -> throw IllegalArgumentException("Line has wrong size")
                }
            }

        }

    }

    class Column(cells: List<Cell>) {

        companion object {
            fun from(rows: List<Row>, index: Int): Column = Column(rows.map { it.get(index) })
        }

        val completelyMarked = cells.all(Cell::isMarked)

    }

    data class Cell(val number: Int, val marked: Boolean) {

        fun isMarked(): Boolean = marked

        fun copyWithMarked(numberToCheck: Int): Cell = when(number == numberToCheck) {
            true -> Cell(number, true)
            false -> this
        }

        override fun toString(): String = when (marked) {
            false -> number.toString()
            true -> "X"
        }.padStart(2)

        companion object {

            fun from(line: String): Cell = Cell(line.toInt(), false)

        }

    }

    companion object {

        fun from(lines: List<String>, size: Int): Board = when (lines.size) {
            size -> Board(lines.map { Row.from(it, size) }, size, null)
            else -> throw IllegalArgumentException("Board has wrong size")
        }

    }

}

fun main() {
    println(Day04.partOne())
    println("---")
    println()
    println(Day04.partTwo())
}
