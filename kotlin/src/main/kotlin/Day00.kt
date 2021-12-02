/*
 Generic Functions
 */

fun String.isBlank(): Boolean = this.isEmpty() || this.trim().isEmpty()

fun Int.isGreaterThan(other: Int): Boolean = this > other
