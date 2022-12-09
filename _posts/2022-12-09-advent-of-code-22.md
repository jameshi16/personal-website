---
title: Advent of Code 22
date: 2022-12-09 20:20 +0000
published: true
---

**EDIT**: [Day 9](#day-9) is up!

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

<img src="/images/20221209_1.png" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Interpreting multi-string with JavaScript"/>
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

# Day 6

Oh no I can feel the deadlines! I've decided to take a crack at implementing another thing in C. Since I was also feeling lazy, I decided to use C.


## Part 1

Today's puzzle involves us picking out the position of the first unique character in a sliding frame of 4. The most obvious algorithm is generally as follows:

1. Load the first 4 characters into a set
2. If the set has a length of 4, then you are done, position 4 is the answer
3. Otherwise, go on to the next position, load the previous 3 characters and itself into a set, and check length of set
4. If length is 4, current position is the answer, otherwise, repeat step 3

The above algorithm is probably also the fastest I know, since the set operations involved is `O(4)`. Iterating through the string, that's `O(n)`, so the total runtime of this solution would be `O(4n)`.

In C, however, we don't have sets, and I don't really feel like implementing one. Instead, I employed a technique known as dynamic programming to implement something like a queue, which memorizes 4 values at once. Whenever a new character is read from the input stream, the head of the queue is popped, and the new character is pushed into the queue.

To speed up figuring out if there are any duplicate elements, I created a map of 26 characters and maintain a reference count of each alphabet in the queue. In theory, the function will simply need to iterate through the queue, lookup the alphabet in the map, look at the reference count, and if it's all 1, we've found our character.

This method has a rough time complexity of: `O(n)` for going through the string, `O(4)` for the dynamic programming implementation, `O(4)` for checking the queue. If 4 is an unknown, this'll be `O(k^2 * n)`. Damn.

So:

```c
#include <stdlib.h>
#include <stdio.h>

int main() {
  FILE *f = fopen("input.txt", "r");
  char exist_map[26] = {0};
  char *a = NULL, *b = NULL, *c = NULL, *d = NULL;
  size_t n_processed = 0;
  char buf = 0;

  while ((buf = fgetc(f)) != EOF) {
    ++n_processed;

    if (exist_map[buf - 'a'] == 0 && a != NULL && *a == 1 && *b == 1 && *c == 1) {
      printf("delimiter found at %lu\n", n_processed);
      break;
    }
    if (a) *a -= 1;
    d = exist_map + (buf - 'a');
    *d += 1;
    a = b; b = c; c = d; d = NULL;
  }
  fclose(f);
  return 0;
}

```

The dynamic programming implementation can be improved, but oh well.

## Part 2

Increasing the required unique characters from 4 to 14 would have been much easier on Python, but in C, this means I had to abstract my functions, and use an array of `char*` instead of defining each position in the queue on my own.

The two functions to abstract are:

- the one that figures out if all the reference counts relevant to the queue is 1
- the one that shifts the queue to the left by 1, and adding the new value into the queue

Improving the "queue" can be easily seen in this example, which involves introducing variables to keep a pointer of where the head and tail is. However, I was lazy. So:

```c
#include <stdlib.h>
#include <stdio.h>

char areOnes(char** pointers, size_t size) {
  for (size_t i = 0; i < size - 1; i++)
    if (*(pointers[i]) != 1) return 0;
  return 1; 
} 
  
void leftShiftExistMap(char* map, char** pointers, char newVal, size_t size) {
  if (pointers[0]) *(pointers[0]) -= 1;
  pointers[size - 1] = map + (newVal - 'a');
  *(pointers[size - 1]) += 1;
  for (size_t i = 0; i < size - 1; i++)
    pointers[i] = pointers[i + 1];
  pointers[size - 1] = NULL;
}   
    
int main() {
  FILE *f = fopen("input.txt", "r");
  char exist_map[26] = {0};
  char *pointers[14] = {NULL};
  size_t n_processed = 0;
  char buf = 0;

  while ((buf = fgetc(f)) != EOF) {
    ++n_processed;

    if (exist_map[buf - 'a'] == 0 && pointers[0] != NULL && areOnes(pointers, 14)) {
      printf("delimiter found at %lu\n", n_processed);
      break;
    }
    leftShiftExistMap(exist_map, pointers, buf, 14);
  }
  fclose(f);
  return 0;
}
```

The time complexity is still the same, which is `O(k^2*n)` where `k = 14`. Use the right tools (i.e. Python) for the right job!

# Day 7

After a mere 4 hours of sleep, I continued to rush deadlines fueled by nothing but coffee in my stomach. Suffice to say, I'm not entirely satisfied with the work I've turned in, but what's done is done, am I right?

Day 7 was done together with Day 8, because time was just simply not on my side. But hey, I've done both, cut me some slack!

## Part 1

An interesting use case is presented in day 7, where we essentially had to rebuild the folder structure based on the output of a few commands, and figure out the sum of the set of folders (including subdirectories) that exceeds 100000.

My very tired and uncaffeinated (half-life of coffee was out) brain immediately thought "trees" and jumped straight into the code. We also have to write a simple parser to figure out what each line in the output did / displayed, so that we can use the information meaningfully.

So the sub-problems were:

- Figure out what each line said (parsing);
- Create a new node if the line enters a directory.

Parsing each line is simple, by using spaces as delimiters and tokenizing each word:

```python
tokens = x.strip().split(' ')  # x is a line
if tokens[0] == "$":
  if tokens[1] == 'ls':
    # do something
  elif tokens[2] == '..':
    # do something
  elif tokens[2] == '/':
    # do something
  else:
    # do something, is a directory
elif tokens[0].isdigit():
    # is size of file
elif tokens[0] == 'dir':
    # is telling us directory exist
```

All we need to do now is to create a `Node` class that represents our tree:

```python
class Node:
  def __init__(self, dirname, parent = None):
    self.dirname = dirname
    self.value = None
    self.parent = parent
    self.nodes = []

  def __eq__(self, other):
    return self.dirname == other.dirname

  def __hash__(self):
    return hash(self.dirname)

  def __str__(self):
    return "{} {}".format(self.dirname, [str(n) for n in self.nodes])

  def getSize(self):
      return self.value if self.value is not None else sum([x.getSize() for x in self.nodes])
```

And then combine all the code together. I also add a `getSolutionSize` function in `Node`, which traverses the tree depth-first, gets the space occupied on the diskif it's larger than `100000` (specified in the problem), and accumulates the size.:

```python
import functools
import sys

class Node:
  def __init__(self, dirname, parent = None):
    self.dirname = dirname
    self.value = None
    self.parent = parent
    self.nodes = []

  def __eq__(self, other):
    return self.dirname == other.dirname

  def __hash__(self):
    return hash(self.dirname)

  def __str__(self):
    return "{} {}".format(self.dirname, [str(n) for n in self.nodes])

  def getSolutionSize(self):
    if self.value is not None:
      return 0
    else:
      size = self.getSize()
      return (0 if size > 100000 else size) + sum([x.getSolutionSize() for x in self.nodes])

  def getSize(self):
      return self.value if self.value is not None else sum([x.getSize() for x in self.nodes])

def parselines(xs, rootNode, node):
  if xs == []: return

  x = xs[0]
  tokens = x.strip().split(' ')
  if tokens[0] == "$":
    if tokens[1] == 'ls':
      parselines(xs[1:], rootNode, node)
    elif tokens[2] == '..':
      parselines(xs[1:], rootNode, node.parent)
    elif tokens[2] == '/':
      parselines(xs[1:], rootNode, rootNode)
    else:
      n = Node(tokens[2], node)
      if n in node.nodes:
        n = node.nodes[node.nodes.index(n)]
      parselines(xs[1:], rootNode, n)
  elif tokens[0].isdigit():
    n = Node(tokens[1], node)
    n.value = int(tokens[0])
    node.nodes.append(n)
    parselines(xs[1:], rootNode, node)
  elif tokens[0] == 'dir':
    n = Node(tokens[1], node)
    node.nodes.append(n)
    parselines(xs[1:], rootNode, node)

n = Node('/')
data = open("input.txt", "r").readlines()[1:]
sys.setrecursionlimit(len(data) * 2)
parselines(data, n, n)
print(n.getSolutionSize())
```

Because we use recursion extensively, we have to increase our recursion limit to something we can work with.

## Part 2

In Part 2, we find the folder with lowest value that is greater than the free space we need. Luckily, this is a small change (I use tuples, but actually we can just omit the `dirname` to remove that information, as we don't need it for our solution):

```python
import functools
import sys

class Node:
  def __init__(self, dirname, parent = None):
    self.dirname = dirname
    self.value = None
    self.parent = parent
    self.nodes = []

  def __eq__(self, other):
    return self.dirname == other.dirname

  def __hash__(self):
    return hash(self.dirname)

  def __str__(self):
    return "{} {}".format(self.dirname, [str(n) for n in self.nodes])

  def getSolution(self, target):
    if self.value is not None:
      return (self.dirname, 999999)
    else:
      bestTuple = (self.dirname, self.getSize())
      for x in self.nodes:
        childTuple = x.getSolution(target)
        if childTuple[1] > target and childTuple[1] < bestTuple[1]:
          bestTuple = childTuple
      return bestTuple

  def getSize(self):
      return self.value if self.value is not None else sum([x.getSize() for x in self.nodes])

def parselines(xs, rootNode, node):
  if xs == []: return

  x = xs[0]
  tokens = x.strip().split(' ')
  if tokens[0] == "$":
    if tokens[1] == 'ls':
      parselines(xs[1:], rootNode, node)
    elif tokens[2] == '..':
      parselines(xs[1:], rootNode, node.parent)
    elif tokens[2] == '/':
      parselines(xs[1:], rootNode, rootNode)
    else:
      n = Node(tokens[2], node)
      if n in node.nodes:
        n = node.nodes[node.nodes.index(n)]
      parselines(xs[1:], rootNode, n)
  elif tokens[0].isdigit():
    n = Node(tokens[1], node)
    n.value = int(tokens[0])
    node.nodes.append(n)
    parselines(xs[1:], rootNode, node)
  elif tokens[0] == 'dir':
    n = Node(tokens[1], node)
    node.nodes.append(n)
    parselines(xs[1:], rootNode, node)

n = Node('/')
data = open("input.txt", "r").readlines()[1:]
sys.setrecursionlimit(len(data) * 2)
parselines(data, n, n)
print(n.getSolution(30000000 - 70000000 + n.getSize()))
```

`70000000` is the total disk space and `30000000` is the free space we need. The only change was to `getSolutionSize()`, which was changed to `getSolution()`:

```python
  def getSolution(self, target):
    if self.value is not None:
      return (self.dirname, 999999)
    else:
      bestTuple = (self.dirname, self.getSize())
      for x in self.nodes:
        childTuple = x.getSolution(target)
        if childTuple[1] > target and childTuple[1] < bestTuple[1]:
          bestTuple = childTuple
      return bestTuple
```

The code block figures out if a child is closer to the target value than itself, done recursively.

# Day 8

Are you tired of human-readable code yet?

## Part 1

This is a classic problem, in the sense that many applications rely on figuring out if adjacent cells are blocking the view of a current cell. An example could be collision detection (blocking view distance = 1). The problem we are trying to solve, in programmer terms, is: given grid of numbers, find out if all the numbers to any of the edges of the grid are less than the value at the current (x,y).

Interestingly, this problem doesn't have sub-problems, since it's quite a well-contained problem. The algorithm to solve this would be:

1. Go through every x and y starting from `(1, 1)`, ending at `(max_x - 1, max_y - 1)`
2. Iterate from `0 to x - 1`, find out if there are any values that exceed the value at (x,y)
3. Repeat step 2 for `x + 1` to `max_x - 1`
4. Repeat step 2 for `0` to `y - 1`
5. Repeat step 2 for `y + 1` to `max_y - 1`
6. If any of steps 2 to 5 reports that there are no values that exceed the value at (x,y), then the current (x,y) has met the target condition.
7. Collect all the results, and count all (x,y)s that met the condition in step 6

The code, is hence:

```python
import itertools
trees = [[int(y) for y in x if y != '\n'] for x in open('input.txt', 'r').readlines()]
result = itertools.starmap(lambda row, r_trees: list(itertools.starmap(lambda col, tree: all([trees[c_u][col + 1] < tree for c_u in range(0, row + 1)]) or all([trees[c_d][col + 1] < tree for c_d in range(row + 2, len(trees))]) or all([trees[row + 1][r_l] < tree for r_l in range(0, col + 1)]) or all([trees[row + 1][r_r] < tree for r_r in range(col + 2, len(r_trees))]), enumerate(r_trees[1:-1]))), enumerate(trees[1:-1]))

print(sum([sum(r) for r in result]) + len(trees) * 2 + len(trees[0]) * 2 - 4)
```

The most readable thing on the planet, I know.

## Part 2

Instead of figuring out how many (x,y)s have larger values than all the values to any edges of the grid, we now compute a score for each (x,y) based on _how many_ values there is until the current value `<=` a value along the path to the edge of the grid, composited with multiplication.

It's really changing the function `all` to `sum list itertools.takewhile`, which sums the list of True values, while current value is still more than the values it traverses to reach the edge. As the stopping number themselves is counted into the sum (+1), we need to handle the case where all of the numbers were lower than the value at (x,y), which shouldn't have the +1 offset. A `min` function is applied to handle that case. So:

```python
import itertools
trees = [[int(y) for y in x if y != '\n'] for x in open('input.txt', 'r').readlines()]
result = itertools.starmap(lambda row, r_trees: list(itertools.starmap(lambda col, tree: min(sum(list(itertools.takewhile(lambda x: x, [trees[c_u][col + 1] < tree for c_u in range(row, -1, -1)]))) + 1, row + 1) * min(sum(list(itertools.takewhile(lambda x: x, [trees[c_d][col + 1] < tree for c_d in range(row + 2, len(trees))]))) + 1, len(trees) - row - 2) * min(sum(list(itertools.takewhile(lambda x: x, [trees[row + 1][r_l] < tree for r_l in range(col, -1, -1)]))) + 1, col + 1) * min(sum(list(itertools.takewhile(lambda x: x, [trees[row + 1][r_r] < tree for r_r in range(col + 2, len(r_trees))]))) + 1, len(r_trees) - col - 2), enumerate(r_trees[1:-1]))), enumerate(trees[1:-1]))

print(max([max(r) for r in result]))
```

# Day 9

Ah yes, nothing like simulating ropes innit?

## Part 1

Our adventures today bring us to simulating a head and tail, where tail has well-defined behaviour, which the prompt has kindly provided:

- if the head and tail are on different rows and columns, move towards the head diagonally
- else, move towards the head laterally / vertically.

The head is given a list of directions and number of squares to move. So, the sub-problems are:

- parse instruction and number of squares to move
- every time the head moves, check if the tail needs to move
    - if the tail is within 1 square of the head, then it doesn't need to move
    - otherwise, move based on the behaviour given by the prompt
- once the next position of the tail is decided, put it in the set
- at the end of the procedure, count the number of elements in the set

My code today is a lot more readable, so it's quite obvious how the sub-problems are defined:

```python
head_instructions = [(direction, int(value.strip())) for direction, value in [x.split(' ') for x in open('input.txt', 'r').readlines()]]

tail_positions = {(0, 0)}
last_head_pos = (0, 0)
last_tail_pos = (0, 0)
for instruction in head_instructions:
  dir, val = instruction
  h_x,h_y = last_head_pos
  t_x,t_y = last_tail_pos

  step = -1 if dir in 'LD' else 1

  for incr in [step] * val:
    h_y += step if dir in 'UD' else 0
    h_x += step if dir in 'LR' else 0

    if abs(h_x - t_x) <= 1 and abs(h_y - t_y) <= 1:
      continue
    else:
      t_x += int(0 if h_x == t_x else (h_x - t_x) / abs(h_x - t_x))
      t_y += int(0 if h_y == t_y else (h_y - t_y) / abs(h_y - t_y))
      tail_positions.add((t_x, t_y))

  last_head_pos = (h_x, h_y)
  last_tail_pos = (t_x, t_y)

print(len(tail_positions))
```

## Part 2

Part 2 gives us more points to control (i.e. the tail follows a point which follows another point, etc until the head). This means we have to maintain the positions of all the points, and compare the positions pairwise. Luckily for us, the behaviour is the same. So, for each step in our instructions, we go through the positions pairwise and to update positions. Since we are interested in how the tail moves, we only store all the co-ordinates visited by the tail in our set.

So:

```python
head_instructions = [(direction, int(value.strip())) for direction, value in [x.split(' ') for x in open('input.txt', 'r').readlines()]]

tail_positions = {(0, 0)}
last_positions = 10 * [(0, 0)]
for instruction in head_instructions:
  dir, val = instruction
  step = -1 if dir in 'LD' else 1

  for incr in [step] * val:
    g_x, g_y = last_positions[0]
    g_y += step if dir in 'UD' else 0
    g_x += step if dir in 'LR' else 0
    last_positions[0] = (g_x, g_y)
    for i in range(len(last_positions) - 1):
      h_x,h_y = last_positions[i]
      t_x,t_y = last_positions[i + 1]

      if abs(h_x - t_x) <= 1 and abs(h_y - t_y) <= 1:
        continue
      else:
        t_x += int(0 if h_x == t_x else (h_x - t_x) / abs(h_x - t_x))
        t_y += int(0 if h_y == t_y else (h_y - t_y) / abs(h_y - t_y))
        if i + 1 == 9:
          tail_positions.add((t_x, t_y))

      last_positions[i] = (h_x, h_y)
      last_positions[i + 1] = (t_x, t_y)

print(len(tail_positions))
```
