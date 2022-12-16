---
title: Advent of Code 22
date: 2022-12-16 01:10 +0000
published: true
---

**EDIT**: [Day 15](#day-15) is up!

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

<img src="/images/20221216_1.png" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Interpreting multi-string with JavaScript"/>
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

# Day 10

CPU instructions!

## Part 1

This problem is what I would classify as a parser-type problem; it usually involves the programmer writing some sort of basic parser.

The sub-problems are:

- For each line, split the line by the space character
- Based on the instruction:
    - `addx` increment cycles by two, figure out if within the two increments if we've crossed `20` or `- 20 mod 40`, and modify the signal strength accordingly
    - `noop` increment cycles by one, figure out if we've crossed `20` or `- 20 mod 40`, and modify the signal strength accordingly

Thinking that this would be easy to do in Haskell, I gave it a go:

```haskell
inputStr = ""

solution :: String -> Integer
solution input = (\(_,_,z) -> z) $ foldr (\accum (x:xs) -> step x (if null xs then 0 else (read $ head xs)) accum) (1,1,0) $ map words $ lines input
  where  
        stepAddX x accum@(cycles,sums,sigstr) y = if ((cycles + y) == 20) || ((cycles + y - 20) `mod` 40 == 0) then (cycles + 2, sums + x, sigstr + if y == 1 then sums * (cycles + y) else (sums + x) * (cycles + y)) else (cycles + 2, sums + x, sigstr)
        step "noop" _ accum@(cycles,sums,sigstr) = if ((cycles + 1) == 20) || ((cycles + 1 - 20) `mod` 40 == 0) then (cycles + 1, sums, sigstr + sums * (cycles + 1)) else (cycles + 1, sums, sigstr)
        step "addx" x accum@(cycles,_,_) = stepAddX x accum (if odd cycles then 1 else 2)
```

Compiles fine, but gives nonsensical values. I'll give you some time, figure out what may have went wrong here.

Have you thought about it yet?

Right, the reason why this doesn't work, is because we're talking about `20` and `-20 mod 40`, which is a step function. The key to this error is `foldr`, which **processes elements starting from the last element**. This costed me 3 hours, no joke.

So, the final code works once I changed `foldr` to `foldl`, which processes lists starting from the first element.

```haskell
inputStr = ""

solution :: String -> Integer
solution input = (\(_,_,z) -> z) $ foldl (\accum (x:xs) -> step x (if null xs then 0 else (read $ head xs)) accum) (1,1,0) $ map words $ lines input
  where
        stepAddX x accum@(cycles,sums,sigstr) y = if ((cycles + y) == 20) || ((cycles + y - 20) `mod` 40 == 0) then (cycles + 2, sums + x, sigstr + if y == 1 then sums * (cycles + y) else (sums + x) * (cycles + y)) else (cycles + 2, sums + x, sigstr)
        step "noop" _ accum@(cycles,sums,sigstr) = if ((cycles + 1) == 20) || ((cycles + 1 - 20) `mod` 40 == 0) then (cycles + 1, sums, sigstr + sums * (cycles + 1)) else (cycles + 1, sums, sigstr)
        step "addx" x accum@(cycles,_,_) = stepAddX x accum (if odd cycles then 1 else 2)
```

## Part 2

Each day's part 2 is typically a quick edit of each day's part 1. However, not for this particular sub-problem. By changing the purpose of the CPU instructions, I had to pretty much change my entire function definition.

Luckily for me, for the most part, `cycles` and `sums` still have the same concepts. Hence, the only thing I really needed to modify was `sigstr`, and how I render the output:

```haskell
import Data.List.Split (chunksOf)

inputStr = ""

solution :: String -> [String]
solution input = (\(_,_,z) -> chunksOf 40 $ reverse z) $ foldl (\accum (x:xs) -> step x (if null xs then 0 else (read $ head xs)) accum) (1,1,"#") $ map words $ lines input
  where
        isWithin cycles x = (cycles `mod` 40) < x + 3 && (cycles `mod` 40) >= x
        step "noop" _ (cycles,lastx,result) = (cycles + 1, lastx, (if (isWithin (cycles + 1) lastx) then '#' else '.') : result)
        step "addx" x (cycles,lastx,result) = (cycles + 2, lastx + x, (if isWithin (cycles + 2) (lastx + x) then '#' else '.') : (if isWithin (cycles + 1) lastx then '#' else '.') : result)
```

The answer would be a list of Strings, which I then manually copy and paste into a text editor to reformat into text that had any meaning to me.

# Day 11

I'll be honest; this is the hardest part 2 yet. I solved part 2 instinctual, but it took a long time for me to figure out _why_ my solution worked.

## Part 1

Part 1 is quite simple; in simple programmer terms, we have some queues of items, and move the items around based on conditions that have its parameters changed based on the input.

Let's deconstruct the problem a little bit more:

- The condition parameters are:
    - the operator, which is either `+` or `*`
    - the operand, which is either a fixed integer, or `old`, which refers to the value of the item
- Based on the condition being true/false, the item is redirected to another queue also defined by the input. e.g. If condition is true, send to queue 2. Else, send to queue 3.

So, the sub-problems are:

- Parse the input into blocks
- Extract the necessary information from each block: starting items, the operation, the operand, the test parameter, and the queues to send the item to depending on the condition
- For each round, for each block, send items to their new queues based on the condition
- Get the top two queues that processed the most items

I decided to write my code with some level of structure this time round, because the implementation is slightly complicated compared to the past days.

```python
from itertools import islice
from functools import reduce

class Monkey:
  def __init__(self, block):
    self.items_inspected = 0
    self.parse_block(block)
  
  def parse_block(self, block):
    self.id = int(block[0].split(' ')[1][:-1])
    self.items = Queue()
    [self.items.put(int(x.rstrip(' ,'))) for x in block[1].split(' ')[2:]]
    self.operation = (lambda x,y: x*y) if block[2].split(' ')[4] == '*' else (lambda x,y: x+y)
    self.is_mult = block[2].split(' ')[4] == '*'
    self.operand = block[2].split(' ')[5]
    self.test = int(block[3].split(' ')[3])
    self.true_result = int(block[4].split(' ')[5])
    self.false_result = int(block[5].split(' ')[5])
  
  def throw_items(self, monkeys):
    while not self.items.empty():
      item = self.items.get()
      worry = self.operation(item, item if self.operand == 'old' else int(self.operand)) // 3 
      monkeys[self.true_result if worry % self.test == 0 else self.false_result].items.put(worry)
      self.items_inspected += 1

def processor(monkeys, target_rounds):
  for n_rounds in range(target_rounds):
    for monkey in monkeys:
      monkey.throw_items(monkeys)
  
  best_two = list(islice(sorted(monkeys, key=lambda x: x.items_inspected, reverse=True), 2))
  return best_two[0].items_inspected * best_two[1].items_inspected

if __name__ == '__main__':
  lines = open('input.txt', 'r').readlines()
  blocks = reduce(lambda accum, line: accum + [[]] if line == '\n' else accum[:-1] + [accum[-1] + [line.strip()]], lines, [[]])
  monkeys = [Monkey(block) for block in blocks]

  print(processor(monkeys, 20))
```

## Part 2

In this part, the condition was changed to no longer include the `// 3`, meaning that the numbers grew out of proportion, especially when we want 10000 rounds. In Python, large integers, although take time to function, and hence, the program will take too long to complete.

Hence, part 2's prompt suggested that we find a better way to represent the `worry` variable. I went to inspect the counts of the queue at the end of 10, 20 and 30 rounds; even though there is some correlation in the rate of change of counts, it is not strictly linear. This is because the operations are different; inspect the input:

```
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
```

There is a high probability that a value will go through queues 0, 3, and 1, but a probability still exists that it will go through queue 2, which affects the final queue count. Hence, attempting to map the queue count linearly is not viable.

The next thing I looked at was the input. I tried to think about how the operations will affect the divisibility of the items and concluded (after 30 minutes of thinking) that there is no fixed pattern, due addition. If all operations were multiplications, then the story would be different; we would be able to definitively tell if a number will be divisible by the condition the first time we look at the item, or the operand.

The next observation I made was that each test was relatively constant; they are always in the format: `divisible by <prime number>`. For a moment, I thought of some math, like "how would I know if 2^x + 3^y = 7n, where x, y, n are natural numbers?" -> the answer is I have no idea.

Then, my instincts took over and I just replaced `// 3` with `mod (sum of all test prime numbers in the input)` and ran the script on the input without blinking twice. To my surprise, it worked; it was one of those situations where my instincts completed its processes far ahead of the capabilities of my logical thinking.

The code change was one of those that looks insignificant (it literally replaces 4 characters with a modulo), but had a few hours of effort put into it.

```python
from queue import Queue
from itertools import islice
from functools import reduce

class Monkey:
  def __init__(self, block):
    self.items_inspected = 0
    self.parse_block(block)

  def parse_block(self, block):
    self.id = int(block[0].split(' ')[1][:-1])
    self.items = Queue()
    [self.items.put(int(x.rstrip(' ,'))) for x in block[1].split(' ')[2:]]
    self.operation = (lambda x,y: x*y) if block[2].split(' ')[4] == '*' else (lambda x,y: x+y)
    self.is_mult = block[2].split(' ')[4] == '*'
    self.operand = block[2].split(' ')[5]
    self.test = int(block[3].split(' ')[3])
    self.true_result = int(block[4].split(' ')[5])
    self.false_result = int(block[5].split(' ')[5])

  def throw_items(self, monkeys):
    while not self.items.empty():
      item = self.items.get()
      worry = self.operation(item, item if self.operand == 'old' else int(self.operand)) % (2 * 17 * 7 * 11 * 19 * 5 * 13 * 3)
      monkeys[self.true_result if worry % self.test == 0 else self.false_result].items.put(worry)
      self.items_inspected += 1

def processor(monkeys, target_rounds):
  for n_rounds in range(target_rounds):
    for monkey in monkeys:
      monkey.throw_items(monkeys)

  best_two = list(islice(sorted(monkeys, key=lambda x: x.items_inspected, reverse=True), 2))
  return best_two[0].items_inspected * best_two[1].items_inspected

if __name__ == '__main__':
  lines = open('input.txt', 'r').readlines()
  blocks = reduce(lambda accum, line: accum + [[]] if line == '\n' else accum[:-1] + [accum[-1] + [line.strip()]], lines, [[]])
  monkeys = [Monkey(block) for block in blocks]

  print(processor(monkeys, 1000))
```

After taking a shower, my logical thinking finally reached a conclusion.

Let's break this down into a much simpler problem. Let's say we have two test prime numbers, 2 and 3. There are 4 things that could possibly happen after applying the operation to our item's value:

1. It's divisible by 2 and not divisible by 3;
2. It's not divisible by 2 and divisible by 3;
3. It's divisible by 2 and divisible by 3;
4. It's not divisible by 2 and not divisible by 3.

So, if we were to talk about the possible values of each of the bullet points:

1. [2, 4, 8, 10, etc]
2. [3, 6, 9, 15, etc]
3. [6, 12, 18, 24, etc]
4. [1, 5, 7, 11, etc]

Let's think about all the numbers in their prime factors:

1. [2, 4, 2 * 3 + 2, 2 * 3 + 4, etc]
2. [3, 6 + 0, 2 * 3 + 3, 2^2 * 3 + 3, etc]
3. [2 * 3, 2^2 * 3, 2 * 3^2, 2^3 * 3^2, etc]
4. [1, 5, 2 * 3 + 1, 2 * 3 + 5, etc]

If we link this to our question, we realise that our these numbers are a combination of multiplication and addition. A further observation suggests that all numbers more than 6 can be broken down into `n = q * 6 + r`, where `n` is the original number, `q` is some number, and `r` is a number less than 6. We then realize that `r` is the remainder, and we also know that `n % 6 == r`.

We then realize that if we add a number, `m`, such that `n` is still not divisible by 6, and `r + m < 6` then: `n + m = q * 6 + r + m`. Since `n + m` is not divisible by 6, then surely `r + m` is not divisible by 6. Likewise, for 2: `r + m < 6`, then: `n + m = q * 6 + r + m`, since `n + m` is not divisible by 2, then surely `r + m` is not divisible by 2, and so on. This wouldn't work if we try to test for divisibility by 7: `r + m < 6` then: `n + m =/= q * 6 + r + m`, `r + m` not divisible by 7 (which is the case for all possible values of `r + m`, since `r + m` is within 0 to 6) does not necessarily mean `n + m` is not divisible by 7.

So, what this means is that any addition that does not make the expression immediately divisible by **`6` is added to the remainder**, and we know that the **modulo of the remainder is equal to the modulo of the original number**. Since `6` can be broken down into the primes `2` and `3`, which are our test prime numbers, therefore, by performing modulo on all the test prime numbers within our input, we can fully express the divisibility of our number with any one of the primes just by maintaining the remainder.

Hence, 

```python
      worry = self.operation(item, item if self.operand == 'old' else int(self.operand)) % (2 * 17 * 7 * 11 * 19 * 5 * 13 * 3)
```

must work (the prime numbers are the terms I'm too lazy to evaluate).

# Day 12

Today is quite obviously a path-finding challenge.

## Part 1

Admittedly, I spend an embarrassing amount of time figuring out that while I can only go up by one altitude unit at a time, I can actually descend more than 1 level at a time. I decided to use Breadth First Search to perform path-finding, since it's good enough for the use case.

For every node I've visited, I replace it's position with `#`, which denotes a visited node. So:

```python
grid = [[y for y in x.strip()] for x in open('input.txt', 'r').readlines()]   
grid[0][20] = 'a'
                                                                              
def bfs(pos):
  q = Queue()                                                                 
  p = Queue()                                                                 
  q.put(pos)
  
  count = 0
  while True:                                                                 
    while not q.empty():                                                      
      x, y = q.get()                                                          
      elevation = 'a' if grid[y][x] == 'S' else grid[y][x]                    
      grid[y][x] = '#'                                                        
      moves = [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]                
      
      if elevation == 'E': 
        return count                                                          
      
      for new_x, new_y in moves:                                              
        if 0 <= new_x < len(grid[0]) and 0 <= new_y < len(grid) \             
          and grid[new_y][new_x] != '#' \                                     
          and (-999 <= ord(grid[new_y][new_x]) - ord(elevation) <= 1 \        
          or (elevation == 'z' and grid[new_y][new_x] == 'E')):               
            p.put((new_x, new_y))
          
    count += 1
    q = p 
    p = Queue()                                                               
    
print(bfs((0, 20)))
```

It might be worth it to mention that `-999` is too large of a magnitude. `-2` would have been good enough; this means that I would be able to descend a maximum of `-2`. Experimental results for the win.

Also, if you think hard-coding the starting position is hacky, then you can look away.

## Part 2

Part 2 requires us to find a better starting position, so that we minimize the amount of steps it takes to reach the peak, denoted by `E`. So, I first approached the problem the dumb way, which was to iterate through all positions of `a`, the lowest altitude, and accumulate the minimum.

Obviously, that was slow, so I thought about using another algorithm, like Dijkstra's Shortest Path algorithm; however, there would be no benefit whatsoever over BFS since the weights of each nodes are the same.

Hence, I decided to perform a reverse BFS; instead of checking for `E`, I check for the closest `a`, given that we can instead ascend 2 levels and descend only 1 level (inverse of our ascending constraints).

So:

```python
from queue import Queue                                                       

grid = [[y for y in x.strip()] for x in open('input.txt', 'r').readlines()]

def bfs(pos):
  q = Queue()
  p = Queue() 
  q.put(pos) 
      
  count = 0
  while True: 
    while not q.empty():
      x, y = q.get()
      elevation = 'z' if grid[y][x] == 'E' else grid[y][x]
      grid[y][x] = '#'
      moves = [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]
        
      if elevation == 'a':
        return count
          
      for new_x, new_y in moves:
        if 0 <= new_x < len(grid[0]) and 0 <= new_y < len(grid) \
          and grid[new_y][new_x] != '#' \
          and (-1 <= ord(grid[new_y][new_x]) - ord(elevation) <= 2 \
          or (elevation == 'a' and grid[new_y][new_x] == 'S')):
            p.put((new_x, new_y))
    count += 1
    q = p
    p = Queue()

print(bfs((len(grid[0]) - 22, 20)))
```

# Day 13

Nothing like spending 5 hours on Advent of Code, eh?

Felt a little down, so I decided to use good old C to do this. Little did I know, that was going to be a huge ordeal.

## Part 1

This part was essentially about parsing. I may be able to summarize what I've essentially did here, but the process to get there is error-prone; I had to painstakingly debug the corner cases that occurred during my parsing.

In hindsight, it might have been a better idea to list all the possible corner cases before attempting the problem. 

The input we are to parse can come in the following format:

```
[[[[3],[]],5],[[],[7,[3,3,3],2,[1],[6,7,9]],[],8,1],[9,[0,0,[5,3,5,1],[2],2],3],[2,[0,4]]]
[[[]],[[[],10,[8,0,5,5],[5,4,8,10,1],[6,8,0,3,5]],2,[9,[5],[9,2],[]],[8,[]]]]
```

Defining the first list as 'a', and the second list as 'b', if:

- We are comparing two lists, then we compare elements in the two lists
    - If list 'a' terminates early (less elements than 'b'), then the two lists are in order
    - If list 'b' terminates early (less elements than 'a'), then the two lists are not in order
- We are comparing two values, then we just take the integers and directly compare them
- We are comparing a list and a value, in which we re-package the value as a singleton list, and attempt to compare them again.

Sounds easy, but it was actually much more difficult than I imagined. I converted each comparison method above into their own function, and wrapped all three functions around a main function called "think" that decides which comparison method to choose based on the current tokens. I then confirmed that the list pairs are either greater, or less than one another. Hence, I was able to discard all thoughts related to equality.

Now, time to think about each case step by step, which I only thought was a good idea in hindsight. Let's say the current character in 'a' and 'b' are 'x' and 'y':

1. If 'x' and 'y' are '[' then we use the list comparison method
2. If 'x' and 'y' does not have any list-related symbols ('[' and ']'), then we use the value comparison method
3. Else:
    1. If 'x' denotes the end of the list and 'y' is a value, we compare the number of lists open in 'a' and 'b' at the moment, and return 1 or -1 if they are not the same. Otherwise, we get the successor of x, and start from step 1 again. This allows us to reach a point where we can compare two values, or return early if the list sizes assert that they're unequal.
    2. If 'x' is a value and 'y' denotes the end of the list, we compare the number of lists open in 'a' and 'b' at the moment, and return 1 or -1 if they are not the same value. Otherwise, we get the successor of y, and start from step 1 again.
    3. If both 'x' and 'y' denotes the end of the list, we compare the number of lists open in 'a' and 'b' just in case, and gets the successor of both 'x' and 'y', repeating step 1.
4. Else, if we can tell that 'x' is a value while 'y' is a list, we use the re-packaging comparison method
5. Else, if we can tell that 'x' is a list while 'y' is a value, we use the re-packaging comparison method, but we negate the value we acquire from the method.

Embarrasingly enough, it took me a long time to figure out that two digit numbers exist within our problem-space; I've been comparing ASCII for a few hours not knowing why my solution didn't work.

With the steps described above, it becomes possible to define a recursive function that steps through the list, building kinda like a syntax tree on the stack:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int comparevaluethenlist(char* a, char* b, size_t l_levels, size_t r_levels, int c);
int comparevalue(char* a, char* b, size_t l_levels, size_t r_levels, int c);
int comparelist(char* a, char* b, size_t l_levels, size_t r_levels, int c);
int think(char* a, char* b, size_t l_levels, size_t r_levels, int c);

int comparevaluethenlist(char* a, char* b, size_t l_levels, size_t r_levels, int c) {
  return think(a, b + 1, l_levels + 1, r_levels + 1, c + 1);
}

int think(char* a, char* b, size_t l_levels, size_t r_levels, int c) {
  if (*a == '[' && *b == '[') {
    int res = comparelist(a, b, l_levels, r_levels, c);
    if (res == -1 || res == 1) return res;
  } else if (*a != '[' && *a != ']' && *b != '[' && *b != ']')
    return comparevalue(a, b, l_levels, r_levels, c);
  else if (*a == ']' && *b != ']') {
    l_levels--;
    if (l_levels < r_levels) return -1;
    if (l_levels > r_levels) return 1;

    a++;
    if (*a == ',') a++;
    return think(a + 1, b, l_levels, r_levels, c);
  } else if (*a != ']' && *b == ']') {
    r_levels--;
    if (l_levels < r_levels) return -1;
    if (l_levels > r_levels) return 1;

    b++;
    if (*b == ',') b++;
    return think(a, b + 1, l_levels, r_levels, c);
  } else if (*a == ']' && *b == ']') {
    l_levels--;
    r_levels--;

    if (l_levels < r_levels) return -1;
    if (l_levels > r_levels) return 1;

    a++;
    b++;
    if (*a == ',') a++;
    if (*b == ',') b++;
    return think(a, b, l_levels, r_levels, c);
  } else {
    if (*a != '[' && *a != ']')
      return comparevaluethenlist(a, b, l_levels, r_levels, c);
    else if (*b != '[' && *b != ']')
      return -comparevaluethenlist(b, a, r_levels, l_levels, c);
  }
}

int comparevalue(char* a, char* b, size_t l_levels, size_t r_levels, int c) {

  char numBufA[20];
  char numBufB[20];
  char *tokA_com = strchr(a, ','), *tokA_brac = strchr(a, ']'), 
    *tokB_com = strchr(b, ','), *tokB_brac = strchr(b, ']');
  char *tokA = (tokA_com < tokA_brac && tokA_com != NULL) ? tokA_com : tokA_brac;
  char *tokB = (tokB_com < tokB_brac && tokB_com != NULL) ? tokB_com : tokB_brac;
  strncpy(numBufA, a, tokA - a);
  numBufA[tokA - a] = '\0';

  strncpy(numBufB, b, tokB - b);
  numBufB[tokB - b] = '\0';

  int a_i = 0, b_i = 0;
  a_i = atoi(numBufA);
  b_i = atoi(numBufB);

  if (a_i > b_i) return 1;
  if (a_i < b_i) return -1;
  a += tokA - a;
  b += tokB - b;

  if (c && *b == ',') return -1;
  if (c && *b != ',' && *a == ',') return 1;

  if (*a == ',') a++;
  if (*b == ',') b++;

  return think(a, b, l_levels, r_levels, c);
}

int comparelist(char* a, char* b, size_t l_levels, size_t r_levels, int c) {
  l_levels++;
  r_levels++;
  a++; b++;

  if (*a == ',') a++;
  if (*b == ',') b++;

  return think(a, b, l_levels, r_levels, c);
}


int parse(char* line1, char* line2) {
  return comparelist(line1, line2, 0, 0, 0);
}

int main() {
  unsigned long accum = 0, count = 0;;
  char line1[1000], line2[1000];
  FILE *f = fopen("input.txt", "r");
  do {
    count++;
    fscanf(f, "%s\n", line1);
    fscanf(f, "%s\n", line2);
    int val = parse(line1, line2);
    if (val == -1) {
      accum += count;
    }
  } while (!feof(f));
  fclose(f);

  printf("Result: %ld\n", accum);

  return 0;
}
```

After some hours of debugging, I also had to introduce `c` to maintain information that we are currently within a list that has been _upgraded_ from a value for the sake of comparison, so that we can return early upon encountering a `,`. This has by far the most corner cases in this problem.

## Part 2

Part 2 repurposes the `think` function into a binary comparison function. Luckily, I have already defined `think` to return values required by the `qsort` standard library function, so I simply used that, and appended `[[2]]` and `[[6]]` into the `input.txt` file, and multiplied their indices after sorting to acquire the final solution:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int comparevaluethenlist(char* a, char* b, size_t l_levels, size_t r_levels, int c);
int comparevalue(char* a, char* b, size_t l_levels, size_t r_levels, int c);
int comparelist(char* a, char* b, size_t l_levels, size_t r_levels, int c);
int think(char* a, char* b, size_t l_levels, size_t r_levels, int c);

int comparevaluethenlist(char* a, char* b, size_t l_levels, size_t r_levels, int c) {
  return think(a, b + 1, l_levels + 1, r_levels + 1, c + 1);
}

int think(char* a, char* b, size_t l_levels, size_t r_levels, int c) {
  if (*a == '[' && *b == '[') {
    int res = comparelist(a, b, l_levels, r_levels, c);
    if (res == -1 || res == 1) return res;
  } else if (*a != '[' && *a != ']' && *b != '[' && *b != ']')
    return comparevalue(a, b, l_levels, r_levels, c);
  else if (*a == ']' && *b != ']') {
    l_levels--;
    if (l_levels < r_levels) return -1;
    if (l_levels > r_levels) return 1;

    a++;
    if (*a == ',') a++;
    return think(a + 1, b, l_levels, r_levels, c);
  } else if (*a != ']' && *b == ']') {
    r_levels--;
    if (l_levels < r_levels) return -1;
    if (l_levels > r_levels) return 1;

    b++;
    if (*b == ',') b++;
    return think(a, b + 1, l_levels, r_levels, c);
  } else if (*a == ']' && *b == ']') {
    l_levels--;
    r_levels--;

    if (l_levels < r_levels) return -1;
    if (l_levels > r_levels) return 1;

    a++;
    b++;
    if (*a == ',') a++;
    if (*b == ',') b++;
    return think(a, b, l_levels, r_levels, c);
  } else {
    if (*a != '[' && *a != ']')
      return comparevaluethenlist(a, b, l_levels, r_levels, c);
    else if (*b != '[' && *b != ']')
      return -comparevaluethenlist(b, a, r_levels, l_levels, c);
  }
}

int comparevalue(char* a, char* b, size_t l_levels, size_t r_levels, int c) {
  char numBufA[20];
  char numBufB[20];
  char *tokA_com = strchr(a, ','), *tokA_brac = strchr(a, ']'), 
    *tokB_com = strchr(b, ','), *tokB_brac = strchr(b, ']');
  char *tokA = (tokA_com < tokA_brac && tokA_com != NULL) ? tokA_com : tokA_brac;
  char *tokB = (tokB_com < tokB_brac && tokB_com != NULL) ? tokB_com : tokB_brac;
  strncpy(numBufA, a, tokA - a);
  numBufA[tokA - a] = '\0';

  strncpy(numBufB, b, tokB - b);
  numBufB[tokB - b] = '\0';

  int a_i = 0, b_i = 0;
  a_i = atoi(numBufA);
  b_i = atoi(numBufB);

  if (a_i > b_i) return 1;
  if (a_i < b_i) return -1;
  a += tokA - a;
  b += tokB - b;

  if (c && *b == ',') return -1;
  if (c && *b != ',' && *a == ',') return 1;

  if (*a == ',') a++;
  if (*b == ',') b++;

  return think(a, b, l_levels, r_levels, c);
}

int comparelist(char* a, char* b, size_t l_levels, size_t r_levels, int c) {
  l_levels++;
  r_levels++;
  a++; b++;

  if (*a == ',') a++;
  if (*b == ',') b++;

  return think(a, b, l_levels, r_levels, c);
}

int comparison(const void* line1, const void* line2) {
  return comparelist((char*) line1, (char*) line2, 0, 0, 0);
}

int main() {
  unsigned long count = 0;
  unsigned long result = 0;
  char lines[1000][1000];
  FILE *f = fopen("input.txt", "r");
  while (!feof(f))
    fscanf(f, "%s\n", lines[count++]);
  fclose(f);

  qsort(lines, count, 1000 * sizeof(char), comparison);

  for (int i = 0; i < count; i++) {
    if (strcmp(lines[i], "[[2]]") == 0)
      result = i + 1;
    
    if (strcmp(lines[i], "[[6]]") == 0)
      result *= i + 1;
  }

  printf("Result: %ld\n", result);

  return 0;
}
```

# Day 14

Bury me in sand, please.

## Part 1

Today's problem involved the following sub-problems:

1. Drawing lines on a grid;
2. Simulating the behaviour of sand particles, where:
    1. If it can go down, it goes down
    2. If it can't go down, but can go bottom left, do that
    3. If it can't go down, but can go bottom right, do that
    4. If it can't go anywhere, settle the sand and move on to the next sand

What about the size of the grid? Well, since our input is fixed, we really don't have to figure that out; just guess a large enough size, I'm sure that won't come back to bite me in the future :new_moon_with_face:. The first sub-problem was easily solved like so:

```python
grid = [['.' for _ in range(600)] for _ in range(200)]

with open('input.txt', 'r') as f:
  line = f.readline()
  while line:
    if line:
      xys = [tuple(map(lambda y: int(y), x.split(','))) for x in line.split(' ') if x != '->']
      for i in range(len(xys) - 1):
        x1, y1 = xys[i]
        x2, y2 = xys[i + 1]
        while abs(x1 - x2) > 0:
          grid[y1][x1] = '#'
          x1 += -1 if x1 > x2 else 1

        while abs(y1 - y2) > 0:
          grid[y1][x1] = '#'
          y1 += -1 if y1 > y2 else 1
      
        grid[y1][x1] = '#'
    line = f.readline()
```

The input looks like this:

```
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
```

So, when parsing each line, we need to strip spaces, filter out `->`, and split the resultant string by `,`. We also want to convert each list of strings into a tuple of integers, so we also do that in the same line.

For each adjacent `x` and `y`, we attempt to draw the walls that will affect sand interactions.

To solve the next sub-problem, we convert the behavior in to a bunch of if statements, and keep looping until one grain of sand enters the void, defined by anything falling out of `y = 200`:

```python
voided = False
settled_grains = 0
while not voided:
  grain_x, grain_y = (500, 0)
  is_occupied = lambda x: x == '#' or x == '+'
  settled = False
  while not settled:
    if grain_y + 1 >= 200:
      voided = True
      break
    elif not is_occupied(grid[grain_y + 1][grain_x]):
      grain_y += 1
    elif grain_x - 1 >= 0 and not is_occupied(grid[grain_y + 1][grain_x - 1]):
      grain_x -= 1
      grain_y += 1
    elif grain_x + 1 < 600 and not is_occupied(grid[grain_y + 1][grain_x + 1]):
      grain_x += 1
      grain_y += 1
    else:
      settled = True
      grid[grain_y][grain_x] = '+'

  if not voided:
    settled_grains += 1
```

Piecing it all together:

```python
grid = [['.' for _ in range(600)] for _ in range(200)]

with open('input.txt', 'r') as f:
  line = f.readline()
  while line:
    if line:
      xys = [tuple(map(lambda y: int(y), x.split(','))) for x in line.split(' ') if x != '->']
      for i in range(len(xys) - 1):
        x1, y1 = xys[i]
        x2, y2 = xys[i + 1]
        while abs(x1 - x2) > 0:
          grid[y1][x1] = '#'
          x1 += -1 if x1 > x2 else 1

        while abs(y1 - y2) > 0:
          grid[y1][x1] = '#'
          y1 += -1 if y1 > y2 else 1

        grid[y1][x1] = '#'
    line = f.readline()

voided = False
settled_grains = 0
while not voided:
  grain_x, grain_y = (500, 0)
  is_occupied = lambda x: x == '#' or x == '+'
  settled = False
  while not settled:
    if grain_y + 1 >= 200:
      voided = True
      break
    elif not is_occupied(grid[grain_y + 1][grain_x]):
      grain_y += 1
    elif grain_x - 1 >= 0 and not is_occupied(grid[grain_y + 1][grain_x - 1]):
      grain_x -= 1
      grain_y += 1
    elif grain_x + 1 < 600 and not is_occupied(grid[grain_y + 1][grain_x + 1]):
      grain_x += 1
      grain_y += 1
    else:
      settled = True
      grid[grain_y][grain_x] = '+'

  if not voided:
    settled_grains += 1

print(settled_grains)
```

## Part 2

In this part, we realize that the void doesn't exist (damn it, there goes one option). Instead, there is an infinite floor at `max_y + 2`, where `max_y` is the largest `y` found while parsing the lines.

Luckily for me, that was simple to do; we just store the maximum `y` every time we see one:

```python
        highest_y = max(y1, y2, highest_y)
```

Then, after reading the entire input, we just fill that `y` with the floor symbol:

```python
grid[highest_y + 2] = ['#' for _ in range(600)]
```

Next, our stop condition has changed to sand particles settling at `(500, 0)`, meaning that the generator of sand particles will subsequently be blocked.

```python
    else:
      settled = True
      grid[grain_y][grain_x] = 'o'
      if (grain_x, grain_y) == (500, 0):
        settled_grains += 1
        stop = True
        break
```

However, all these changes weren't enough, as I was greeted by the "wrong answer" prompt on AOC. Turns out, due to the floor, the sand particles tend to create large pyramids. This means that there is a large base, which can't fit into our grid. Incidentally, I decided to re-assign settled grains as `'o'`, to differentiate between falling grains and settled grains.

Luckily, since we know our sand particles are generated from `(500, 0)`, we know for sure that the maximum `x` is somewhere around `750` due to how equilateral triangles work. To be safe, we increase the grid size all the way to `1000`. So, the final code looks like this.

```python
grid = [['.' for _ in range(1000)] for _ in range(200)]

with open('input.txt', 'r') as f:
  line = f.readline()
  highest_y = 0
  while line:
    if line:
      xys = [tuple(map(lambda y: int(y), x.split(','))) for x in line.split(' ') if x != '->']
      for i in range(len(xys) - 1):
        x1, y1 = xys[i]
        x2, y2 = xys[i + 1]
        highest_y = max(y1, y2, highest_y)
        while abs(x1 - x2) > 0:
          grid[y1][x1] = '#'
          x1 += -1 if x1 > x2 else 1

        while abs(y1 - y2) > 0:
          grid[y1][x1] = '#'
          y1 += -1 if y1 > y2 else 1

        grid[y1][x1] = '#'
    line = f.readline()
grid[highest_y + 2] = ['#' for _ in range(1000)]

stop = False
settled_grains = 0
while not stop:
  grain_x, grain_y = (500, 0)
  is_occupied = lambda x: x == '#' or x == 'o'
  settled = False
  while not settled:
    if grain_y + 1 >= 200:
      stop = True
      break
    elif not is_occupied(grid[grain_y + 1][grain_x]):
      grain_y += 1
    elif grain_x - 1 >= 0 and not is_occupied(grid[grain_y + 1][grain_x - 1]):
      grain_x -= 1
      grain_y += 1
    elif grain_x + 1 < 1000 and not is_occupied(grid[grain_y + 1][grain_x + 1]): #and not is_occupied(grid[grain_y][grain_x + 1]):
      grain_x += 1
      grain_y += 1
    else:
      settled = True
      grid[grain_y][grain_x] = 'o'
      if (grain_x, grain_y) == (500, 0):
        settled_grains += 1
        stop = True
        break

  if not stop:
    settled_grains += 1

print(settled_grains)
```

# Day 15

Today was an excellent lesson in how time & space can grow into sizes that would be noticeable.

## Part 1

In pure logical terms, there are two entities in question: the sensor, and the beacon. Both of these entities have a position, and can be mapped with the relation: `sensor -> beacon`.

The problem constraints that the position are integers, and each relation `sensor -> beacon` represents the sensor to its closest beacon in Manhattan distance.

> Manhattan distance is the distance in the x-axis + the distance in the y-axis, which is different from typical distance that is typically the hypotenuse of x and y.

With the constraints out of the way, behold the question: get the number of positions that is not within the Manhattan distance of any `sensor -> beacon` relation. The position is constraint by y, so we essentially get a row of positions that fulfils the condition.

At first, I thought about performing a BFS on every source, and then marking visited nodes. Then, I just count the number of unmarked nodes, and we'd be done. Of course, this works, but subsequently, the puzzle input looks like this:

```
Sensor at x=2832148, y=322979: closest beacon is at x=3015667, y=-141020
Sensor at x=1449180, y=3883502: closest beacon is at x=2656952, y=4188971
```

which I interpreted as "aw crap, I'd need like a hundred gigabytes of memory to store a grid that size". Instead, let's approach the problem from another angle: we take the possible positions, which is defined by the minimum `x` and `y` seen in the input minus the largest distance we know, to the maximum `x` and `y` plus the largest distance. Luckily for us, since `y` is constrained to a single row, we only need to process one row, and `x` columns.

Then, calculate the Manhattan distance from the possible positions to every sensor, and check if they are less than the distance within the `sensor -> beacon` relation. If they are, then those positions are considered visited; otherwise, those positions are unvisited. Finally, just count the number of unvisited positions, as required of us.

The above text is summarized as:

1. Parse input
2. For each unvisited position, for each sensor, check if distance from sensor to position is less than relation distance
3. If all distances are more than relation distance, count it as unvisited
4. Repeat 2 until all possible positions have been tested
5. Return number of unvisited position

Code:

```python
min_x, min_y = 0, 0
max_x, max_y = 0, 0
max_dist = 0
coordinate_map = dict()
beacons = set()

with open('input.txt', 'r') as f:
  line = f.readline()
  while line:
    tokens = line.strip().split(' ')
    s_x = int(tokens[2].rstrip(',').split('=')[1])
    s_y = int(tokens[3].rstrip(':').split('=')[1])
    b_x = int(tokens[8].rstrip(',').split('=')[1])
    b_y = int(tokens[9].rstrip(',').split('=')[1])
    min_x = min(s_x, b_x, min_y)
    min_y = min(s_y, b_y, min_y)
    max_x = max(s_x, b_x, max_x)
    max_y = max(s_y, b_y, max_y)
    dist = abs(b_x - s_x) + abs(b_y - s_y)
    max_dist = max(max_dist, dist)

    coordinate_map[(s_x, s_y)] = dist
    beacons.add((b_x, b_y))
    line = f.readline()

target_y = 2000000
count = 0
for x in range(min_x - max_dist, max_x + max_dist + 1):
  for k, v in coordinate_map.items():
    s_x, s_y = k
    dist = abs(x - s_x) + abs(target_y - s_y)
    if (x, target_y) not in beacons and (x, target_y) not in coordinate_map and dist <= v:
      count += 1
      break

print(count)
```

## Part 2

Part 2 requires us to limit our search space and find one position that all beacons cannot reach; the problem guarantees that there is only 1 such position within the x and y constraints. Our y-constraint is released, which creates a huge problem for us; now, our constraints are x between 0 to 4000000 and y between 0 to 4000000.

If I were to draw a grid, and assuming each unit of data we talk about here is 1 byte, that's like 16 terabytes of data. 'Tis but a small issue, let's just buy more RAM.

Luckily, part 1 doesn't really store anything in a grid; we have great space complexity, so why not just use it? Turns out, we will experience time issues; even though the algorithm is O(x * n) in time-complexity, where `x` is the column size of the theoretical grid and `n` is the number of sensors, the algorithm in this new context is now O(y * x * n), since `y` is no longer just a constant. `n` is a small number, so it basically doesn't matter, but `x` and `y` _multiplied_ together is _huge_. Suffice to say, the code doesn't finish with a few hours.

Instead, let's slightly change how we approach the problem; instead of finding unreachable locations line by line, we make the following observations instead:

- The unreachable location _must_ exist outside the boundary of the Manhattan distance in the `sensor -> beacon` relation.
- Since there is only _one_ unreachable location, the unreachable location _must_ be within Manhattan distance + 1, but not within Manhattan distance.
- The unreachable location is, well, unreachable from all the sensors.

Hence, we can generate all the points between Manhattan distance and Manhattan distance + 1.

However, this presents a problem; if the Manhattan distance is some absurd size, like 100000, and we have 16 sensors, then we have an absurd number of generated points, which should be 16 * 4 * 100000 = 6400000 points. If each point takes 16 bytes to store, as each number is an Int, then we get 102,400,000 bytes, which is 102.4GB of RAM. No biggie, just buy more RAM, amirite?

Well ok, we've reduced the storage our solution requires from 16TB to 102.4GB, which is 0.64% of the original size we needed, which is **an improvement** :tada:. However, that's not good enough. So what do we do instead?

We make sacrifices in time. Now, for _every_ `sensor` position, we generate all the unreachable locations from that one sensor position, and check if the unreachable locations is also unreachable from every _other_ `sensor` position. Rinse and repeat until we find that one bloody point.

Originally, if we burned 102.4GB of RAM, then our time complexity would be O(m * n), where `m` is the number of points generated, `n` is the number of `sensor` positions. Now, we burn a cool 100MB of RAM, and have a time complexity of O(m * n^2). In this particular case, I feel that this is a perfectly reasonable trade-off for our problem.

Hence, the Python code:

```python
coordinate_map = dict()
beacons = set()

with open('input.txt', 'r') as f:
  line = f.readline()
  while line:
    tokens = line.strip().split(' ')
    s_x = int(tokens[2].rstrip(',').split('=')[1])
    s_y = int(tokens[3].rstrip(':').split('=')[1])
    b_x = int(tokens[8].rstrip(',').split('=')[1])
    b_y = int(tokens[9].rstrip(',').split('=')[1])
    dist = abs(b_x - s_x) + abs(b_y - s_y)

    coordinate_map[(s_x, s_y)] = dist
    beacons.add((b_x, b_y))
    line = f.readline()

def sensor_barrier_coords(sensor_pos):
  s_x, s_y = sensor_pos
  dist = coordinate_map[sensor_pos] + 1
  res = set()

  for i in range(dist + 1):
      res.add((s_x + i, s_y + (dist - i)))
      res.add((s_x - i, s_y - (dist - i)))
      res.add((s_x + i, s_y - (dist - i)))
      res.add((s_x - i, s_y + (dist - i)))

  return res

for k, _ in coordinate_map.items():
  for pos in sensor_barrier_coords(k):
    exclusive = True
    x, y = pos
    if pos in beacons or pos in coordinate_map:
      continue

    if x < 0 or x > 4000000 or y < 0 or y > 4000000:
      continue

    for k1, v in coordinate_map.items():
      s_x, s_y = k1

      dist = abs(x - s_x) + abs(y - s_y)
      if dist <= v:
        exclusive = False
        break

    if exclusive:
      print(x * 4000000 + y)
      exit()
```

> `x * 4000000 + y` is just the problem statement's instruction on how to encode the answer for AOC to check if the result is valid.
