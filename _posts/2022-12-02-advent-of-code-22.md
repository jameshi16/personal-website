---
title: Advent of Code 22
date: 2022-12-02 19:51 +0000
published: true
---

:coffee: Hi!

After having absolutely _zero_ blog posts for the past 11 months, including my treasured [anime](/anime) page, here I am declaring that I will be participating in the [Advent of Code](https://adventofcode.com/) (AOC).

I've never completed an AOC before, so it'll be a nice challenge to breathe vitality into this blog before the New Years. To motivate me, I have invited my buddies over at [modelconverge](https://modelconverge.xyz) and [nikhilr](https://nikhilr.io) to join me.

Each of us will attempt each AOC, and discuss our solutions at the end of each week to judge each solution with its time-space complexity, and elegance. We will use any language we have at our disposal.

Throughout AOC, I will update this blog post in a rolling manner to discuss my thought processes from ideation to solution. Do check back every day!

# Day 1

Thanks to deadlines being a thing, I ended up doing Day 1 24 hours late. Anyways, it seems like we need to make a simple program to figure out who is carrying the most amount of calories among the elves.

## Part 1

I broke down the problem into processing chunks of numbers at once:

1. Each block is delimited by `\n\n` (two newlines), and
2. Each calorie-qualifying item is delimited by `\n`.

So, the steps to solve this problem will be:

1. Define a list, `l`;
2. Read input line by line;
3. For each line, check if the string is just space;
4. If it is just space, we add an integer, `0` into the list, `l`;
5. Otherwise, we parse the input as an integer and add it to the last integer in `l`;
6. Repeat step 2 until EOF;
7. We take the maximum of the list `l`, completing our algorithm.

Framing the problem another way, `l` is the accumulator of integers, and we are processing a list of strings with a function that:

1. Adds a new number to the accumulator if string is empty;
2. Otherwise, adds the integer representation of the string into the last element of the accumulator.

Then, we take the maximum of the list. Naturally, this means that the problem can be solved with two lines of Python:

```python
from functools import reduce

print(max((reduce(lambda accum, y: accum + [0] if y == "" else accum[:-1] + [accum[-1] + int(y)], open("input.txt").read().splitlines(), [0]))))
```

Where the contents of `input.txt` are given by the puzzle input.

## Part 2

The second part essentially want us to get the three highest elements in the list. So, just a small tweak to part 1:

```python
from functools import reduce

print(sum(sorted((reduce(lambda accum, y: accum + [0] if y == "" else accum[:-1] + [accum[-1] + int(y)], open("input.txt").read().splitlines(), [0])), reverse=True)[:3]))
```

All I did here was to replace `max` with a composition of `sum` and `sorted`.

# Day 2

## Part 1

Parsing the problem into programmer monkey brain language, the question is essentially:

- Given an input:
    - Each line is a combination of two characters from different source ranges delimited by space, i.e.: `A X` where `A = ['A','B','C']` and `X = ['X','Y','Z']`.
    - Lines delimited by `\n`.
- `A` and `X` are enumeration representations of the possible moves in rock, paper and scissors. The truth table is as follows:

| **Left** | **Right** | **State** |
|----------|-----------|-----------|
|     A    |     X     |    Tie    |
|     B    |     Y     |    Tie    |
|     C    |     Z     |    Tie    |
|     A    |     Y     |    Win    |
|     B    |     Z     |    Win    |
|     C    |     X     |    Win    |
|     A    |     Z     |    Lose   |
|     B    |     X     |    Lose   |
|     C    |     Y     |    Lose   |

- `X`, `Y`, `Z` have a partial score of 1, 2, 3 respectively
- Winning will grant a partial score of 6, Ties will grant 3, and losing will grant 0.

The first thing I did was to "normalize" and simplify the truth table by taking the difference between `X` and `A`. So, before simplification, the table looked like this:

| **Left** | **Right** | **Diff** | **State** |
|----------|-----------|----------|-----------|
|     1    |     1     |     0    |    Tie    |
|     2    |     2     |     0    |    Tie    |
|     3    |     3     |     0    |    Tie    |
|     1    |     2     |     1    |    Win    |
|     2    |     3     |     1    |    Win    |
|     3    |     1     |    -2    |    Win    |
|     1    |     3     |     2    |    Lose   |
|     2    |     1     |    -1    |    Lose   |
|     3    |     2     |    -1    |    Lose   |

I then simplify the table with the following thoughts:
- Consider only the difference and states;
- Losing will grant zero points, which makes it inconsequential in our score calculation, so it can be completely removed.

So, the table looks like this:

| **Diff** | **State** |
|----------|-----------|
|     0    |    Tie    |
|     1    |    Win    |
|    -2    |    Win    |

Now, the problem of obtaining the win/tie/loss partial score has been simplified to check for these 3 cases. So, I could now write something like:

```c
// a is normalized left, x is normalized right
int partial_score = (a == x) * 3 + (x - a == 1 || x - a == -2) * 6;
```

The next sub-problem to tackle will be to normalize our inputs. All ASCII characters can be expressed as integers, and hence can be normalized by the lowest value of each range. In other words:

```c
// a is left, x is right
int normalised_a = a - 'A';
int normalised_x = x - 'X';
```

Performing this normalization almost conforms to the partial sum where `'X', 'Y', 'Z' -> 1, 2, 3`. Right now, the map looks like `'X', 'Y', 'Z' -> 0, 1, 2`. To fix this, just add 1:

```c
// normalised_x as above
int partial_score = normalised_x + 1;
```

So, the total score can now be expressed as:

```c
// a is normalised left, x is normalised right
int score = (x + 1) + (a == x) * 3 + (x - a == 1 || x - a == -2) * 6;
```

All we need to do now is to do the preprocessing and required code to actually obtain `x` and `a`. I first wrote it in C, which looks like this:

```c
#include <stdlib.h>
#include <stdio.h>

int eval_score(char a, char b) {
  char opp_a = a - 'A';
  char opp_b = b - 'X';
  return opp_b + 1 + (opp_b - opp_a == 1 || opp_b - opp_a == -2) * 6 + (opp_a == opp_b) * 3;
}

int main() {
  FILE* file = fopen("input.txt", "r");
  long accum_score = 0;

  do {
    char first, second;
    fscanf(file, "%c %c\n", &first, &second);
    accum_score += eval_score(first, second);
  } while (!feof(file));

  printf("%ld\n", accum_score);

  return 0;
}
```

This was too long, so I decided to re-write the same thing in JavaScript:

```js
inputStr = `` // puzzle input

inputStr.split('\n').reduce((acc, curr) =>
        acc.concat(
                ((codes) => codes[1] + 1 +
                        (codes[1] - codes[0] == 1 || codes[1] - codes[0] == -2) * 6 +
                        (codes[0] == codes[1]) * 3)
                (((raw) => [raw[0].charCodeAt() - 65, raw[1].charCodeAt() - 88])(curr.split(' ')))), [])
        .reduce((acc, curr) => acc + curr, 0)
```

Which is shorter but kinda unreadable.

## Part 2

Part 2 changes the interpretation of `X`. `"X"`, `"Y"`, and `"Z"` now represents `lose`, `tie`, and `win`. Upon closer inspection, this really only affects the partial sum used to calculate the score based on state; if anything, it made calculating the win/loss/tie partial score simple.

It can be easily realised that associating tie to `0`, win to `1` and loss to `-1` will make deriving the rock/paper/scissors move simple.

| **Left** | **State** | **Right**                   |
|----------|-----------|-----------------------------|
|     x    |  Tie (0)  |              x              |
|     x    |  Win (1)  |  0 if x + 1 == 3 else x + 1 |
|     x    | Lose (-1) | 2 if x - 1 == -1 else x - 1 |

Remember that the normalised `"A", "B", "C" -> 0, 1, 2`, so ties would imply `"A", "B", "C" -> Scissors, Paper, Rock`, wins would imply `"A", "B", "C" -> Paper, Rock, Scissors`, and losses will be `"A", "B", "C" -> Scissors, Rock, Paper`.

Hence, the code would be changed to:

```js
inputStr = ``

inputStr.split('\n').reduce((acc, curr) =>
        acc.concat(
                ((codes) => ((codes[0] + codes[1] == -1) ? 2 : (codes[0] + codes[1]) % 3) + 1 +
                        (codes[1] == 1) * 6 +
                        (codes[1] == 0) * 3)
                (((raw) => [raw[0].charCodeAt() - 65, raw[1].charCodeAt() - 89])(curr.split(' ')))), [])
        .reduce((acc, curr) => acc + curr, 0)
```

Notice the change at `raw[1].charCodeAt() - 89`, which essentially absorbed an offset of `-1`.
