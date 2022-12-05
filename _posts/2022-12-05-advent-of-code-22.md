---
title: Advent of Code 22
date: 2022-12-05 23:50 +0000
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

# Day 3

## Part 1

Today's part 1 problem can be broken down into the following sub-problems:

- Go through the input line by line;
- For each line, split the line by half, and find the intersect between the two lines;
- Due to the nature of the problem, it is guaranteed that the intersection is one and unique;
- For each of the intersections, calculate the respective priorities.

I decided to use Haskell, because :shrug:. Inputs in Haskell is notoriously complex, so I decided to bypass that by utilizing my browser's JavaScript engine to convert multi-line strings to normal strings delimited by `\n`, like this:

<img src="/images/20221205_1.png" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Interpreting multi-string with JavaScript"/>
<p class="text-center text-gray lh-condensed-ultra f6">Converting to a single-line string with JavaScript</p>

Doing so, I will be able to bypass all input-related processing in Haskell by assigning the string to the variable.

Let's solve each sub-problem in Haskell:

```haskell
-- input string
input = ""

-- going through line by line
lines input

-- split line by half
splitAt (round $ (/2) $ fromIntegral $ length line) line

-- find intersection between the two halfs
intersect splitted_xs splitted_ys

-- calculate priority
(\x -> if x `elem` ['a'..'z'] then ord x - 96 else ord x - 65 + 27) $ (!! 0) intersected_list
```

Some notes:
- `length line` strictly returns an integer, which needs to be converted for division in Haskell;
- In the priority calculation, we subtract 96, which is 1 less than the ASCII value for 'a', so we introduce an offset of `+1`;
- The range `['A'..'Z']` has an offset of 26 + 1 after getting it's sequence number from the ASCII value for 'A'.

Combining these together, we have:

```haskell
import Data.Char
import Data.List

input = ""
solution input = sum [(\x -> if x `elem` ['a'..'z'] then ord x - 96 else ord x - 65 + 27) $ (!! 0) $ (\(xs, ys) -> intersect xs ys) $ splitAt (round $ (/2) $ fromIntegral $ length line) line | line <- lines input]
```

## Part 2

The slight twist introduced here require us to do the following:

- Group the lines by 3;
- Instead of getting the intersect between the two halves of a string, get the intersect between all elements in the groups of 3.

It is guaranteed by the nature of the problem that our input's number of lines will be divisible by 3.

There are many ways to group the lines by 3, and the way I chose is to maintain an accumulated list of lists, where each element list will contain 3 elements.

With that, we solve the sub-problems:

```haskell
-- grouping the lines by 3
foldr (\x acc@(y:ys) -> if length y == 3 then [x]:acc else (x:y):ys) [[]] $ lines input

-- intersecting 3 lines
map (foldr1 intersect) output_of_above
```

Then, reassembling the final solution:
```haskell
import Data.Char
import Data.List

solution' input = sum $ map ((\x -> if x `elem` ['a'..'z'] then ord x - 96 else ord x - 65 + 27) . (!! 0)) $ map (foldr1 intersect) $ foldr (\x acc@(y:ys) -> if length y == 3 then [x]:acc else (x:y):ys) [[]] $ lines input
```

# Day 4

## Part 1

Feeling a little lazy today, I decided to work in Python. Today's problem is broken down into the following, familiar sub-problems:

1. Read input line by line;
2. Split the line by `,`, which we will call segments;
3. Split the segments by `-`, which we will call fragments;
4. Convert resulting fragments to integers;
5. Figure out if one of the two segments are fully contained in one or another;
6. Count the number of fully contained lines.

Let's talk about step 5. In set theory, if we wanted to know if `A` is fully contained in `B`, then `A⊂B`; however, this can be simplified if `A` and `B` are sorted lists, which is the case for ranges defined solely by their boundaries. So, if I had an input line of `6-6,4-6` we can verify quite quickly that the left range is fully contained in the right range, not because we imagined if all elements of the left range is in the right range, but because of the lower bounds: `6 > 4`, and the upper bounds: `6 == 6`, so therefore `6-6` is in `4-6`.

Similarly, for `2-8,3-7`, we see that `3 > 2` and `7 < 8`, so this means `3-7` must be in `2-8`.

With that context, the sub-problems can be solve like so in Python:

```python
# read input line by line e.g. "2-8,3-7"
open("input.txt", "r").readlines()

# split line by ',', so we get ["2-8", "3-7"]
segments = line.split(',')

# split a single segment by '-' so we get fragment = ["2", "8"]
fragment = segment.split('-')
# note that all fragments = [["2", "8"], ["3", "7"]]

# convert to int [2, 8]
fragment_prime = map(int, fragment)

# compare the ranges
possibility_1 = fragment_1[0] <= fragment_2[0] and fragment_1[1] >= fragment_2[1]
possibility_2 = fragment_2[0] <= fragment_1[0] and fragment_2[1] >= fragment_1[1]
result = possibility_1 or possibility_2
```

The way I used to combine all of the sub-problems together is to use an unholy concoction of maps:
```python
print(sum(list(map(lambda xys: (xys[0][0] <= xys[1][0] and xys[0][1] >= xys[1][1]) or (xys[1][0] <= xys[0][0] and xys[1][1] >= xys[0][1]), list(map(lambda segments: list(map(lambda segment: list(map(int, segment.split('-'))), segments)), list(map(lambda line: line.split(','), open("input.txt", "r").readlines()))))))))
```

## Part 2

Part 2 changes the so-called "set operation" we are performing. Instead of "fully contains", we are looking for overlaps, or in set terms we are looking for, "A∩B≠Ø".

Let's consider the few possible cases, if we have a string in the format `a-b,x-y`:

```
case 1
......a###########b...
.x#y..................

case 2
..a######b...
.x###y....

case 3
..a###b....
....x###y..

case 4
.a####b.......
.........x##y.

case 5
....a####b....
......x#y.....
```

The cases imply the following:

1. No intersect: `a > x`, `b > x`, `x < a`, `y < a`;
2. Intersect: `a > x`, `b > x`, **`x < a`, `y > a`**;
3. Intersect: **`a < x`, `b > x`**, `x > a`, `y > a`;
4. No intersect: `a < x`, `b < x`, `x > a`, `y > a`;
5. Intersect: **`a < x`, `b > x`**, `x > a`, `y > a`.

The relations in bold matter the most; we see that for any two ranges to intersect, the lower bound of the first range must be less than the lower bound of the second range, and the upper bound of the first range must be greater than the lower bound of the second range, *or* vice-versa.

Writing that in code, the testing statement becomes:

```python
possibility_1 = fragment_1[0] <= fragment_2[0] and fragment_1[1] >= fragment_2[0]
possibility_2 = fragment_2[0] <= fragment_1[0] and fragment_2[1] >= fragment_1[0]
result = possibility_1 or possibility_2
```

So, our resulting code looks very similar to part 1, with a minor change of index in our comparison lambda:

```python
print(sum(list(map(lambda xys: (xys[0][0] <= xys[1][0] and xys[0][1] >= xys[1][0]) or (xys[1][0] <= xys[0][0] and xys[1][1] >= xys[0][0]), list(map(lambda segments: list(map(lambda segment: list(map(int, segment.split('-'))), segments)), list(map(lambda line: line.split(','), open("input.txt", "r").readlines()))))))))
```

# Analysis - Week 1

> TODO: I'll populate this later

# Day 5

Deadlines are looming, so I've haven't got the time to compact this. However, a streak is a streak!

## Part 1

Immediately after reading the question, I immediately thought of stacks. The sub-problems are as follows:

1. Split the input into two, the visual representation and the instructions;
2. Break down the visual representation into stacks;
3. Break down the instructions into something we can use;
4. Use the instructions to identify:
    - `from` queue;
    - `to` queue;
    - how many items to move.

Not being in the headspace to do function composition, I left the code separated in their respective chunks:

```python
import functools                                                                              
                                                                                              
data = open('input.txt', 'r').readlines()                                                     
                                                                                              
# \n here is the divider                                                                      
segments = functools.reduce(lambda accum, x: accum[:-1] + [accum[-1] + [x]] if x != '\n' else accum + [[]], data, [[]])

# all characters are +4 away from one another, first one at pos 1. reparse accordingly        
segments[0] = list(map(lambda x: [x[i] for i in range(1, len(x), 4)], segments[0]))

# flatten segments[0] into a queue-like structure                                             
stacks = [[] for i in range(len(segments[0][0]))]                                             
for row in segments[0][:-1]:
  for i, col in enumerate(row):                                                               
    if col != ' ':
      stacks[i].append(col)                                                                   
stacks = [list(reversed(stack)) for stack in stacks]                                          

# flatten segments[1] into a list of tuple instructions                                       
digit_fn = lambda s: [int(x) for x in s.split() if x.isdigit()]                               
instructions = [digit_fn(s) for s in segments[1]]

# do the movements                                                                            
for instruction in instructions:                                                              
  stack_from = instruction[1] - 1                                                             
  stack_to = instruction[2] - 1 
  number = instruction[0]
  
  for _ in range(number):                                                                     
    stacks[stack_to].append(stacks[stack_from].pop()) 
  
# get the top of all                                                                          
print(''.join([s[-1] for s in stacks]))
```

## Part 2

Part 2 essentially changes the data structure we are working with. Now, we're breaking off lists at any arbitrary point, and appending it to another list (is there a name for this type of data structure)?

However, since this is a small change, I decided to change two lines and reuse the rest of the code, meaning that the main data structure in use is misnamed. Regardless, here it is:

```python
import functools                                                                              
                                                                                              
data = open('input.txt', 'r').readlines()                                                     
                                                                                              
# \n here is the divider                                                                      
segments = functools.reduce(lambda accum, x: accum[:-1] + [accum[-1] + [x]] if x != '\n' else accum + [[]], data, [[]])

# all characters are +4 away from one another, first one at pos 1. reparse accordingly        
segments[0] = list(map(lambda x: [x[i] for i in range(1, len(x), 4)], segments[0]))

# flatten segments[0] into a queue-like structure                                             
stacks = [[] for i in range(len(segments[0][0]))]                                             
for row in segments[0][:-1]:
  for i, col in enumerate(row):                                                               
    if col != ' ':
      stacks[i].append(col)                                                                   
stacks = [list(reversed(stack)) for stack in stacks]                                          

# flatten segments[1] into a list of tuple instructions                                       
digit_fn = lambda s: [int(x) for x in s.split() if x.isdigit()]                               
instructions = [digit_fn(s) for s in segments[1]]

# do the movements                                                                            
for instruction in instructions:                                                              
  stack_from = instruction[1] - 1                                                             
  stack_to = instruction[2] - 1 
  number = instruction[0]
  
  stacks[stack_to].extend(stacks[stack_from][-number:])                                       
  stacks[stack_from] = stacks[stack_from][:-number]
  
# get the top of all                                                                          
print(''.join([s[-1] for s in stacks]))
```
