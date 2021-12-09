import kotlin.math.ceil

/*
--- Day 6: Lanternfish ---

The sea floor is getting steeper. Maybe the sleigh keys got carried this way?

A massive school of glowing lanternfish swims past. They must spawn quickly to reach such large numbers - maybe exponentially quickly? You should model their growth rate to be sure.

Although you know nothing about this specific species of lanternfish, you make some guesses about their attributes. Surely, each lanternfish creates a new lanternfish once every 7 days.

However, this process isn't necessarily synchronized between every lanternfish - one lanternfish might have 2 days left until it creates another lanternfish, while another might have 4. So, you can model each fish as a single number that represents the number of days until it creates a new lanternfish.

Furthermore, you reason, a new lanternfish would surely need slightly longer before it's capable of producing more lanternfish: two more days for its first cycle.

So, suppose you have a lanternfish with an internal timer value of 3:

    After one day, its internal timer would become 2.
    After another day, its internal timer would become 1.
    After another day, its internal timer would become 0.
    After another day, its internal timer would reset to 6, and it would create a new lanternfish with an internal timer of 8.
    After another day, the first lanternfish would have an internal timer of 5, and the second lanternfish would have an internal timer of 7.

A lanternfish that creates a new fish resets its timer to 6, not 7 (because 0 is included as a valid timer value). The new lanternfish starts with an internal timer of 8 and does not start counting down until the next day.

Realizing what you're trying to do, the submarine automatically produces a list of the ages of several hundred nearby lanternfish (your puzzle input). For example, suppose you were given the following list:

3,4,3,1,2

This list means that the first fish has an internal timer of 3, the second fish has an internal timer of 4, and so on until the fifth fish, which has an internal timer of 2. Simulating these fish over several days would proceed as follows:

Initial state: 3,4,3,1,2
After  1 day:  2,3,2,0,1
After  2 days: 1,2,1,6,0,8
After  3 days: 0,1,0,5,6,7,8
After  4 days: 6,0,6,4,5,6,7,8,8
After  5 days: 5,6,5,3,4,5,6,7,7,8
After  6 days: 4,5,4,2,3,4,5,6,6,7
After  7 days: 3,4,3,1,2,3,4,5,5,6
After  8 days: 2,3,2,0,1,2,3,4,4,5
After  9 days: 1,2,1,6,0,1,2,3,3,4,8
After 10 days: 0,1,0,5,6,0,1,2,2,3,7,8
After 11 days: 6,0,6,4,5,6,0,1,1,2,6,7,8,8,8
After 12 days: 5,6,5,3,4,5,6,0,0,1,5,6,7,7,7,8,8
After 13 days: 4,5,4,2,3,4,5,6,6,0,4,5,6,6,6,7,7,8,8
After 14 days: 3,4,3,1,2,3,4,5,5,6,3,4,5,5,5,6,6,7,7,8
After 15 days: 2,3,2,0,1,2,3,4,4,5,2,3,4,4,4,5,5,6,6,7
After 16 days: 1,2,1,6,0,1,2,3,3,4,1,2,3,3,3,4,4,5,5,6,8
After 17 days: 0,1,0,5,6,0,1,2,2,3,0,1,2,2,2,3,3,4,4,5,7,8
After 18 days: 6,0,6,4,5,6,0,1,1,2,6,0,1,1,1,2,2,3,3,4,6,7,8,8,8,8

Each day, a 0 becomes a 6 and adds a new 8 to the end of the list, while each other number decreases by 1 if it was present at the start of the day.

In this example, after 18 days, there are a total of 26 fish. After 80 days, there would be a total of 5934.

Find a way to simulate lanternfish. How many lanternfish would there be after 80 days?
 */

/*
--- Part Two ---

Suppose the lanternfish live forever and have unlimited food and space. Would they take over the entire ocean?

After 256 days in the example above, there would be a total of 26984457539 lanternfish!

How many lanternfish would there be after 256 days?
 */

// From: https://adventofcode.com/2021/day/6

object Day06 {

    private const val inputTxt = "input06.txt"

    private const val days1 = 80
    private const val days2 = 256

    /* read input from file */
    private val inputString: String? = javaClass.getResource(inputTxt)?.readText()

    /* convert the inputString to a list of LanternFish (with internal timers) */
    private val population: Population? = inputString?.let(Population::from)

    /* convert the inputString to a reproducingPopulation */
    private val reproducingPopulation: ReproducingLanternFishPopulation? =
        inputString?.let{ ReproducingLanternFishPopulation.from(days2, it) }

    fun partOne(): Int? {

        population ?: return null

        return Population.getEvolvedAfter(days1, population).size  // Unfortunately, this has exponential complexity.
        // For up to about 100 days, this is still acceptable. Thr runtime is about 4-5 seconds.
        // After that, for every 7 days, the runtime grows by a factor of 2 (roughly).
        // That means, for 256 days, the runtime is about 190 days.

    }

    fun partTwo(): Long? {

        reproducingPopulation ?: return null

        /* Due to complexity reasons (see partOne()), we need a different approach here.
        // We can't just iterate over the population and evolve it, because that would take too long.

        // Instead, we can solve it analytically.
        // During their life span, lanternFish will reproduce themselves every 7 days.
        //
        // That means that after 256 days, a single lanternFish will have reproduced itself 256/7 = 37 times.
        // This, of course, depends on the initial timer value of that particular lanternFish, which we shall
        // call the t-value. Then we can calculate the number of reproductions as:
        //
        //    r(x) = ceil((x-t)/7), where x is the number of days and t is the t-value of the lanternFish.
        //
        // Now, the interesting question is: what should we do with the reproductions?
        // The answer is, we can just treat them as new lanternFish with 
        // t-values of 9 + t-value of the lanternFish that spawned them,
        // and an additional 7 for every further reproduction.
        //
        // So we can now solve the puzzle for one lanternFish:
        //
        //    reproductions = list(L(t+9), L(t+9+7), L(t+9+7+7), ...)
        //
        // Then, we only have to iterate over the list, generate new reproductions from them, 
        // and sum it all together.

        Additionally, (and this is even more important) we can also use the fact that
        we can "cache" parts of the process.
        E.g., if we know that a lanternFish with a t-value of 3 will produce a population size of 2
        in 10 days, we can store that information in a map.
        Now, every time we encounter a lanternFish with a t-value of 3, we can just look up the value in the map.

        This makes the algorithm much faster (~7 ms compared to months...).
         */

        return reproducingPopulation.getSize()

    }

}

class ReproducingLanternFishPopulation(private val lanternFish: List<ReproducingLanternFish>, private val days: Int) {

    fun getSize(): Long = lanternFish.sumOf { it.getSizeByCache(sizeByTCache) }

    private val sizeByTCache: MutableMap<Int, Long> = mutableMapOf()

    companion object {

        fun from(days: Int, input: String): ReproducingLanternFishPopulation =
            ReproducingLanternFishPopulation(
                input.split(",").map { ReproducingLanternFish.from(it, days) },
                days
            )

    }

    override fun toString(): String = "After $days days, there are ${getSize()} lanternFish."

}

class LanternFishGeneration(parent: ReproducingLanternFish, children: List<ReproducingLanternFish>) {

    val generation: List<ReproducingLanternFish> =
        listOf(parent, *children.toTypedArray())

}

fun List<LanternFishGeneration>.flatten(): List<ReproducingLanternFish> =
    map(LanternFishGeneration::generation).flatten()

class ReproducingLanternFish(private val days: Int, private val t: Int) {

    private val reproductionCount: Int = ceil((days - t).toDouble() / reproductionRate).toInt()

    private val pivotalRange: IntRange = (days - reproductionRate)..(days + newFishTimer)

    private fun getReproductions(): List<ReproducingLanternFish> =
        (0 until reproductionCount).map { ReproducingLanternFish(days, t + newFishTimer + reproductionRate * it) }

    fun getSizeByCache(cache: MutableMap<Int, Long>): Long = when (t) {
        in cache -> cache[t]!!
        in pivotalRange -> calcSize().also { cache[t] = it }
        else -> getSizeChildren(cache).also { cache[t] = it }
    }

    private fun getSizeChildren(cache: MutableMap<Int, Long>): Long =
        getReproductions().sumOf { it.getSizeByCache(cache) } + 1

    private fun calcSize(): Long = getAllReproductionsNested().flatten().size + 1L

    private fun getAllReproductionsNested(): List<LanternFishGeneration> = getReproductions().map { child ->
        LanternFishGeneration(child, child.getAllReproductionsNested().flatten())
    }

    companion object {

        private const val reproductionRate: Int = 7
        private const val newFishTimer: Int = 9

        fun from(input: String, days: Int): ReproducingLanternFish = ReproducingLanternFish(days, input.trim().toInt())

    }

    override fun toString(): String = t.toString()

}

class Population(private val lanternFish: List<LanternFish>, private val days: Int) {

    val size: Int = lanternFish.map(LanternFish::getRawAge).size

    fun evolve(): Population = Population(lanternFish.map(LanternFish::evolve).flatten(), days + 1)

    companion object {

        fun from(input: String): Population = Population(input.split(",").map(LanternFish::from), 0)

        fun getEvolvedAfter(days: Int, population: Population): Population =
            (0 until days).fold(population) { evolvedPopulation, _ -> evolvedPopulation.evolve() }

    }

    override fun toString(): String = "After $days days: ${lanternFish.joinToString(separator = ",")} ($size)"

}

class LanternFish(private val timer: Byte) {

    fun getRawAge(): Byte = timer

    fun evolve(): List<LanternFish> = when (timer) {
        0.toByte() -> listOf(LanternFish(initialTimer), LanternFish(newFishTimer))
        else -> listOf(LanternFish((timer - 1).toByte()))
    }

    companion object {

        private const val initialTimer: Byte = 6
        private const val newFishTimer: Byte = 8

        fun from(input: String): LanternFish = LanternFish(input.trim().toByte())

    }

    override fun toString(): String = timer.toString()

}

fun measureTimeMillis(block: () -> Unit): Long = System.currentTimeMillis().let { start ->
    block()
    System.currentTimeMillis() - start
}

fun main() {
    println(Day06.partOne())
    println("---")
    println(measureTimeMillis {
        println()
        println(Day06.partTwo())
    })
}
