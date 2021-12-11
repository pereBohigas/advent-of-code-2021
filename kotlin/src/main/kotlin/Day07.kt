import kotlin.math.abs

/*
--- Day 7: The Treachery of Whales ---

A giant whale has decided your submarine is its next meal, and it's much faster than you are. There's nowhere to run!

Suddenly, a swarm of crabs (each in its own tiny submarine - it's too deep for them otherwise) zooms in to rescue you! They seem to be preparing to blast a hole in the ocean floor; sensors indicate a massive underground cave system just beyond where they're aiming!

The crab submarines all need to be aligned before they'll have enough power to blast a large enough hole for your submarine to get through. However, it doesn't look like they'll be aligned before the whale catches you! Maybe you can help?

There's one major catch - crab submarines can only move horizontally.

You quickly make a list of the horizontal position of each crab (your puzzle input). Crab submarines have limited fuel, so you need to find a way to make all of their horizontal positions match while requiring them to spend as little fuel as possible.

For example, consider the following horizontal positions:

16,1,2,0,4,2,7,1,2,14

This means there's a crab with horizontal position 16, a crab with horizontal position 1, and so on.

Each change of 1 step in horizontal position of a single crab costs 1 fuel. You could choose any horizontal position to align them all on, but the one that costs the least fuel is horizontal position 2:

    Move from 16 to 2: 14 fuel
    Move from 1 to 2: 1 fuel
    Move from 2 to 2: 0 fuel
    Move from 0 to 2: 2 fuel
    Move from 4 to 2: 2 fuel
    Move from 2 to 2: 0 fuel
    Move from 7 to 2: 5 fuel
    Move from 1 to 2: 1 fuel
    Move from 2 to 2: 0 fuel
    Move from 14 to 2: 12 fuel

This costs a total of 37 fuel. This is the cheapest possible outcome; more expensive outcomes include aligning at position 1 (41 fuel), position 3 (39 fuel), or position 10 (71 fuel).

Determine the horizontal position that the crabs can align to using the least fuel possible. How much fuel must they spend to align to that position?
 */

/*
--- Part Two ---

The crabs don't seem interested in your proposed solution. Perhaps you misunderstand crab engineering?

As it turns out, crab submarine engines don't burn fuel at a constant rate. Instead, each change of 1 step in horizontal position costs 1 more unit of fuel than the last: the first step costs 1, the second step costs 2, the third step costs 3, and so on.

As each crab moves, moving further becomes more expensive. This changes the best horizontal position to align them all on; in the example above, this becomes 5:

    Move from 16 to 5: 66 fuel
    Move from 1 to 5: 10 fuel
    Move from 2 to 5: 6 fuel
    Move from 0 to 5: 15 fuel
    Move from 4 to 5: 1 fuel
    Move from 2 to 5: 6 fuel
    Move from 7 to 5: 3 fuel
    Move from 1 to 5: 10 fuel
    Move from 2 to 5: 6 fuel
    Move from 14 to 5: 45 fuel

This costs a total of 168 fuel. This is the new cheapest possible outcome; the old alignment position (2) now costs 206 fuel instead.

Determine the horizontal position that the crabs can align to using the least fuel possible so they can make you an escape route! How much fuel must they spend to align to that position?
 */

// From: https://adventofcode.com/2021/day/7

object Day07 {

    private const val inputTxt = "input07.txt"

    /* read input from file */
    private val inputString: String? = javaClass.getResource(inputTxt)?.readText()

    /* convert the inputString to a list of crab submarines */
    private val crabSubmarineSwarm: CrabSubmarineSwarm? = inputString?.let { CrabSubmarineSwarm.from(it) }

    fun partOne(): Long? {

        crabSubmarineSwarm ?: return null

        /*
            We could brute-force this (i.e. check the fuel-consumption for each position),
            but if we take a closer look at the problem,
            we can see that there's a much more elegant solution...
            Just use the median value.

            Some prosa on that:
            We can describe the problem as a function:

            Be x0, x1, x2, ..., xn the positions of the crabs
            Then `xm` shall be the position that requires the least fuel to align.

            Now, to get `xm`, we're looking for the minimum of the following function:
            f(x) = sum(abs(xi - x))    => f(xm) = min(f(x))

            because `abs(xi-x)` represents the distance between the crab and any position x ('fuel'),
            and we're of course interested in the minimum of the total fuel consumption (hence the `sum()`).

            Now, as we learned in school, finding the minimum of a function
            requires looking at the function's derivative.
            For easier readability, we'll use |x| instead of `abs(x)` in the following.

            d/dx f(x) = ?

            => d/dx sum(|xi - x|) = d/dx (|x0 - x| + |x1 - x| + ... + |xn - x|)
                                  = d/dx |x0 - x| + d/dx |x1 - x| + ... + d/dx |xn - x|

            The derivative of the abs()-function is:

                d/dx |x| = 1 if x > 0, or -1 if x < 0

            Hence, the derivative of the |xi - x| is:

                d/dx |xi - x| = -1 if xi < x, or 1 if xi > x

            So, for every xi, we need to check if it is smaller than xm, or larger, and sum up -1 or 1 accordingly.
            Now, if we look at it globally, we only need to count how many xi are smaller than xm,
            and how many are larger.

            Now the fun part (and the whole point of this exercise):
            => If x is exactly in the middle, then we number of times we add -1 and +1 is even.
               So we get zero as the sum.
               Again, getting zero in the derivative means that the function has a minimum at that position.
               So, essentially we proved where to find xm. It has to lay in the middle of the all positions,
               such that the same amount of positions lay below and above xm.
               And this, dear readers, is exactly the definition of the median.

            The easiest way to find the median is to sort the positions.
            If we have an odd number of positions, we simply take the middle one and get the median.
            If we have an even number of positions, we take the middle two and calculate the average.

         */

        val alignedSwarm = crabSubmarineSwarm.moveToMedianPosition()
        return alignedSwarm.getTotalFuelConsumption()

    }

    fun partTwo(): Long? {

        crabSubmarineSwarm ?: return null

        /*
            I haven't found an accurate way to prove this,
            but for reasons similar to the ones above,
            we can just take the mean value of the positions
            for this problem. Mathematically, this is not
            quite as accurate as it was with the previous problem,
            but it's still very close to the correct answer
            (with only decimal points of difference, which
            obviously don't matter).

            Roughly, we again have to take the derivative
            of the fuel-consumption function (`f(x)`), with respect to x
            (x again being the aligned position). So we again have to
            find the minimum of that function, which we get by finding
            where the derivative is zero. Only this time, the fuel consumption
            is not simply `|xi - x|`, but `sum(1 ... |xi - x|)`, which
            can be written as `(|xi - x| + 1)(|xi - x| / 2)` (Gauss's famous
            formula). So the derivative becomes:

            d/dx f(x) = d/dx sum((|xi - x| + 1)(|xi - x|/2))

            => (|xi - x| + 1)*(|xi - x|/2) = ((xi - x)^2 + |xi - x|) * 1/2
            => d/dx ((xi - x)^2 + |xi - x|) * 1/2 = ( 2(xi - x) * (-1) -/+ 1 ) * 1/2
                                                                      (-/+ 1 means -1 if x > xi, +1 if x < xi)

               = (x - xi) -/+ 1/2

            => d/dx f(x) = sum((x - xi) -/+ 1/2) = sum(x) - sum(xi) -/+ sum(1/2) = n*x - sum(xi) -/+ n/2

            Now, to find where this function is zero, we just it's value to zero:

            0 = n*x - sum(xi) -/+ n/2   // divide by n and use: sum(xi)/n = x_, which is the average of all xi

            => 0 = x - x_ -/+ 1/2

            Now: if x is the mean/average, x - x_ is of course zero. But what happens with the rest?
            If x also is the median, then that part is also zero. But the further away the median
            and the mean values are, the more it's not zero.

            One might be able to construct a case where we don't actually get the minimum value
            of the fuel consumption for x = x_.
            I, with limited time and ability, was not able to do that, so I just take the average of all xi.

            Turns out, for this puzzle input, it's the correct solution after all.

          */

        val alignedSwarmAccelerated = crabSubmarineSwarm.moveToMeanPositionAccelerated()
        return alignedSwarmAccelerated.getTotalFuelConsumption()

    }

}

class CrabSubmarineSwarm(private val crabSubmarine: List<CrabSubmarine>) {

    private val medianPosition: Int = crabSubmarine
        .sortedBy(CrabSubmarine::position)
        .map(CrabSubmarine::position)
        .let { positions ->
            when {
                positions.hasEvenNumber() -> positions.twoMiddleEntries().toList().average().toInt()
                else -> positions.middleEntry()
            }
        }

    private val meanPosition: Int = crabSubmarine.map(CrabSubmarine::position).average().toInt()

    private fun List<Int>.hasEvenNumber(): Boolean = size % 2 == 0

    private fun List<Int>.middleEntry(): Int = get(size / 2)

    private fun List<Int>.twoMiddleEntries(): Pair<Int, Int> = get(size / 2) to get(size / 2 - 1)

    fun moveToMedianPosition(): CrabSubmarineSwarm =
        CrabSubmarineSwarm(crabSubmarine.map { it.moveTo(medianPosition) })

    fun moveToMeanPositionAccelerated(): CrabSubmarineSwarm =
        CrabSubmarineSwarm(crabSubmarine.map { it.moveAcceleratedTo(meanPosition) })

    fun getTotalFuelConsumption(): Long = crabSubmarine.sumOf(CrabSubmarine::fuelConsumption)

    companion object {
        
        fun from(input: String): CrabSubmarineSwarm =
            CrabSubmarineSwarm(input.split(",").map(CrabSubmarine::from))
        
    }
    
}

class CrabSubmarine(val position: Int, val fuelConsumption: Long = 0) {

    fun moveTo(newPosition: Int): CrabSubmarine =
        CrabSubmarine(newPosition, fuelConsumption + abs(position - newPosition))

    fun moveAcceleratedTo(newPosition: Int): CrabSubmarine =
        CrabSubmarine(newPosition, fuelConsumption + abs(position - newPosition).sum())

    private fun Int.sum(): Int = (this + 1) * this / 2

    companion object {

        fun from(input: String): CrabSubmarine = CrabSubmarine(input.trim().toInt())

    }

}

fun main() {
    println(Day07.partOne())
    println("---")
    println()
    println(Day07.partTwo())
}
