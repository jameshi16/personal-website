---
title: Advent of Code 22
date: 2022-12-25 12:05 +0000
published: true
tags: [advent, of, code, 2022]
categories: [code, algorithms]
---

:coffee: Hi!

After having absolutely _zero_ blog posts for the past 11 months, including on my treasured [anime](/anime) page, here I am declaring that I will be participating in the [Advent of Code](https://adventofcode.com/) (AOC).

I've never completed an AOC before, so it'll be a nice challenge to breathe vitality into this blog before the New Years. To motivate me, I have invited my buddies over at [modelconverge](https://modelconverge.xyz) and [nikhilr](https://nikhilr.io) to join me.

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

The second part wants us to get the three highest elements in the list. So, just a small tweak to part 1:

```python
from functools import reduce

print(sum(sorted((reduce(lambda accum, y: accum + [0] if y == "" else accum[:-1] + [accum[-1] + int(y)], open("input.txt").read().splitlines(), [0])), reverse=True)[:3]))
```

All I did here was to replace `max` with a composition of `sum` and `sorted`.

----

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

----

# Day 3

## Part 1

Today's part 1 problem can be broken down into the following sub-problems:

- Go through the input line by line;
- For each line, split the line by half, and find the intersect between the two lines;
- Due to the nature of the problem, it is guaranteed that the intersection is one and unique;
- For each of the intersections, calculate the respective priorities.

I decided to use Haskell, because :shrug:. Inputs in Haskell is notoriously complex, so I decided to bypass that by utilizing my browser's JavaScript engine to convert multi-line strings to normal strings delimited by `\n`, like this:

<img src="/images/20221225_1.png" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Interpreting multi-string with JavaScript"/>
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

----

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

----

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

----

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

----

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

----

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

----

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

----

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

----

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

----

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

----

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

----

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

----

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

----

# Day 16

This day was, for lack of a better phrase, really difficult. Part 1 was relatively simple, although I did struggle for a day to get it working, while I needed some hints for part 2.

## Part 1

Part 1 presents an input that looks something like this:

```
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
```

To understand this problem, there are a few pieces of important information that we need to extract from the context:

- Valve `XX` denotes a node;
- `flow rate=xx;` denotes a weight to the node;
- `... DD, II, BB` denotes what the node is connected to.

Each of the valves must be "turned on" to have an impact on the context. The highest sum over a period of 30 units of time will be the solution to the problem.

If we were to directly translate the input to a graph without much thought, we will end up with a undirected cyclic graph, which for lack of a better term, is a pain to work with.

Hence, I decided to boil it down using Dijkstra's Algorithm - before that, I got myself a refresher on how to properly implement priority queues with a flat array, which is possible because it is a complete binary tree.

```python
heap_rep = []

def queue_add(val):
  global heap_rep
  heap_rep.append(val)
  curr_ind = len(heap_rep) - 1

  # => odd number = left child, even number = right child
  parent = (curr_ind - 2) // 2 if curr_ind % 2 == 0 else (curr_ind - 1) // 2
  while parent >= 0 and heap_rep[parent] < heap_rep[curr_ind]:
    heap_rep[parent], heap_rep[curr_ind] = heap_rep[curr_ind], heap_rep[parent]
    curr_ind = parent
    parent = (curr_ind - 2) // 2 if curr_ind % 2 == 0 else (curr_ind - 1) // 2

def queue_pop():
  global heap_rep
  retval = heap_rep[0]
  heap_rep[0], heap_rep[-1] = heap_rep[-1], heap_rep[0]
  ueap_rep = heap_rep[:-1]

  indx = 0
  left_child = indx * 2 + 1
  right_child = indx * 2 + 2

  while (left_child < len(heap_rep) and heap_rep[indx] < heap_rep[left_child]) or (right_child < len(heap_rep) and heap_rep[indx] < heap_rep[right_child]):
    if right_child < len(heap_rep) and heap_rep[left_child] < heap_rep[right_child]:
      heap_rep[indx], heap_rep[right_child] = heap_rep[right_child], heap_rep[indx]
      indx = right_child
    else:
      heap_rep[indx], heap_rep[left_child] = heap_rep[left_child], heap_rep[indx]
      indx = left_child

    left_child = indx * 2 + 1
    right_child = indx * 2 + 2
  return retval

queue_add(14)
queue_add(7)
queue_add(12)
queue_add(18)
queue_add(7)
queue_add(11)
queue_add(20)
queue_add(31)
queue_add(45)

print(heap_rep)
while len(heap_rep) != 0:
  print(queue_pop())
```

> NOTE: Yes, the code looks ugly. It was meant to be a refresher after all!

Then, I used [GeeksForGeeks's](https://www.geeksforgeeks.org/dijkstras-shortest-path-algorithm-greedy-algo-7/) picture of their graph as reference to test my Dijkstra's algorithm:

```python
# testing implementation of d algo

list_of_distances = []
association_list = []

# add some values
association_list.append([(1, 4), (7, 8)])
association_list.append([(0, 4), (7, 11), (2, 8)])
association_list.append([(1, 8), (8, 2), (5, 4), (3, 7)])
association_list.append([(2, 7), (4, 9), (5, 14)])
association_list.append([(3, 9), (5, 10)])
association_list.append([(4, 10), (3, 14), (2, 4), (6, 2)])
association_list.append([(5, 2), (8, 6), (7, 1)])
association_list.append([(0, 8), (8, 7), (1, 11), (6, 1)])
association_list.append([(2, 2), (7, 7), (6, 6)])

# calculate distances
list_of_distances = [999999 for i in range(len(association_list))]
list_of_distances[0] = 0

# non-priority queue implementation
spt_set = set()
while len(spt_set) != len(list_of_distances):
  min_index = 0
  min_distance = 999999
  for k, v in enumerate(list_of_distances):
    if k in spt_set:
      continue

    if v < min_distance:
      min_index = k
      min_distance = v

  spt_set.add(min_index)

  for association in association_list[min_index]:
    list_of_distances[association[0]] = min(min_distance + association[1], list_of_distances[association[0]])

# get path from one to another
print(list_of_distances)
for i in range(1, 9):
  target = i
  path = [i]
  while target != 0:
    min_dist = 999999
    min_ind = 0
    for association in association_list[target]:
      dist = list_of_distances[association[0]] + association[1]
      if dist < min_dist:
        min_ind = association[0]
        min_dist = dist
    path.append(min_ind)
    target = min_ind

  print('->'.join([str(x) for x in reversed(path)]))
```

Great, warm-up done. Let's talk about the problem now.

The distance between each node (that is connected anyway), is actually just 1 unit; so, we boil down those 1-unit nodes into edges. When those nodes become edges, we realize that **information about how we traverse from one node to another is lost**. In other words, we could be doing crazy things like walking back and forth a node but not actually turning on the valve at that node _gasp_. Thankfully, that is **exactly what we want**. The conversion process looks something like this:

```python
def get_distances(source, associations):
  to_visit = PriorityQueue()
  distances = dict()
  for k in associations.keys():
    distances[k] = 999999

  distances[source] = 0
  to_visit.put((0, source))

  while not to_visit.empty():
    _, node = to_visit.get()
    association = associations[node]
    for neighbor in association[1]:
      if distances[neighbor] > distances[node] + 1:
        distances[neighbor] = distances[node] + 1
        to_visit.put((distances[neighbor], neighbor))

  return distances
```

Let's talk about the structure we get from this. If we were to pass `source` the root node, we'll get the minimum spanning tree (i.e. the minimum distance from the current node to any other node in the graph). So, if we were to iterate through a list of _all of the nodes with a valve that has a flow rate_, then we'll get a map of minimum spanning trees from all nodes. Some questions you may now have is:

1. Wouldn't the minimum spanning tree from every other node simply be an adjustment of the distance traveled from the starting node, to the ending node?


    Me: No, because remember that we lost information about how to actually traverse from one node to another; we only know the distance. Imagine a cyclic graph, `A <-> B <-> C <-> D <-> A`, and only `A`, `B` and `D` are nodes with valves, which means a minimum spanning tree that looks like this: `A <-1-> B, A <-3-> D`. If I was at `A`, and I first go to `D`, I travel a distance of `3`. How would I then travel to `B`? We know that the distance from `A` to `D` is `3`, and the distance from `A` to `B` is `1`. So is the answer `4`? Of course not, there is a shorter path that connected `B` to `D` through `C`, which means the answer is actually `2`. but we wouldn't have known that with just the minimum spanning tree of `A`. So, we necessarily must generate the spanning tree of all the node with valves.

2. What is the resulting structure?


   Me: Before I answer this question, let me go through what went through my head for over half a day. "This structure must be a web, because each node has it's own minimum spanning tree!" Naturally, I thought that I ended up with a 3D fully connected web. It took me a while before I was able to re-interpret the graph as a directed acyclic graph, a.k.a a tree. Realizing it is a tree has many benefits, which includes: being able to actually solve the problem. To see how it is a tree, remember that the graph has lost all information about paths through the actual nodes. Then, each node is now represented as actually _turning on_ the nodes, because remember, with information lost about paths, it also suggests that someone could navigate the through the nodes with valves to reach a more important valve before coming back later. Since you are unable to turn on a valve twice, this means that in a graph, the arrow always points outwards, and there will never be a situation where a path will point back to itself. Hence, it is directed and acyclic, which makes the resulting structure a tree.

3. How does this new structure solve the problem?

Now that it's represented as a tree, we can use a variety of ways (like I tried to do) to solve the problem. However, there is one extremely important thing about the problem that makes it challenging to use conventional graph search algorithms: we are _maximizing_ our sum.

All pathfinding algorithm _minimizes_ paths. In a nutshell, this means we have to either look for fantastic heuristics that can turn our maximizing problem into minimizing problems, or figure out another way.

Heuristics are hard, particularly because approximate ones may not yield an accurate result, while an accurate one will either take too long to compute, or is very challenging to define. For instance, A\* Search and Dijkstra both require heuristics to make decisions on what to explore next; if we had heuristics that kept on increasing in value, the pathfinding algorithm will be stuck on a single path, and **we end up with an inaccurate result**. Even if we were to solve that problem by inversing the heuristic, we still find that our reliance on the accumulated pressure, which is always increasing, causes the heuristics to produce inaccurate results. Heuristics work the best if it is calculated between two nodes, and does not have any context-wide variables, such as time, which is required to calculate the total pressure amassed between any two nodes.

Then, you may ask. What about using a slightly inaccurate heuristic, such as `time / pressure`? The larger the time, the more unideal that path. The lower the pressure amassed, the more unideal the path. Perfect!

Perfect?

Well, I tried it out, and it somehow worked for the example, but not the actual input. The rationale is simple: it's actually `(w1 * time) / (w2 * pressure)`, where `w1` and `w2` are arbitrary weights dictating how important time and pressure is. This is the nature of approximation - we need to declare how important something is to the other. However, for our use-case, we need precise answers; hence, even approximate heuristics are not suitable.

There is likely a proper heuristic that can be used for this particular problem, but I decided that it is no longer worth the effort. Instead, I explored BFS and DFS.

I didn't think too much about BFS, because I had a gut feeling that it wouldn't be suitable for the rest of the puzzle; turns out, in part 2, where I actually implement BFS because I ran out of options, I was actually right. The space complexity of BFS is `|V|`, which is synonymous with every node in existence. When we reach part 2, we can see why storing `|V|` is a terrible idea. Meanwhile, for DFS, the space complexity is however many edges we have for the node we are currently processing, which is `|E|`. In a nutshell, for our problem in particular, the storage complexity of DFS is beneficial.

DFS is great because we can do anything with it; even a problem like maximizing accumulated sums. Although there are better ways to do it, like [linear programming](/2022/01/25/duty-planning-with-linear-programming/), the nature of the problem probably disallows us to express the problem as a linear equation (I tried boiling it down to a linear equation, but after spending a fair bit of time, I decided not to).

So, after figuring out that it's a tree, and DFS is the way forward, and attempting to implement the other searches as an experiment, I ended up with a simple implementation like so:

```python
from queue import PriorityQueue

def get_distances(source, associations):
  to_visit = PriorityQueue()
  distances = dict()
  for k in associations.keys():
    distances[k] = 999999

  distances[source] = 0
  to_visit.put((0, source))

  while not to_visit.empty():
    _, node = to_visit.get()
    association = associations[node]
    for neighbor in association[1]:
      if distances[neighbor] > distances[node] + 1:
        distances[neighbor] = distances[node] + 1
        to_visit.put((distances[neighbor], neighbor))

  return distances

def dfs(source, time, pressure, visited, important_nodes):
  if time >= 30:
    return pressure

  distances = get_distances(source, associations)
  best_pressure = pressure

  for impt_node in important_nodes:
    node, (point_pressure, _) = impt_node
    if node in visited:
      continue

    new_time = time + distances[node] + 1
    new_pressure = pressure + point_pressure * (30 - new_time)
    new_visited = visited.copy()
    new_visited.add(node)
    res = dfs(node, new_time, new_pressure, new_visited, important_nodes)
    if res > best_pressure:
      best_pressure = res

  return best_pressure

associations = dict()
with open('input.txt', 'r') as f:
  line = f.readline().strip().split(' ')
  while line[0] != '':
    associations[line[1]] = (int(line[4].rstrip(';').split('=')[1]),
      [valve.strip(',') for valve in line[9:]])
    line = f.readline().strip().split(' ')

print(dfs('AA', 0, 0, set(), [(k,v) for k, v in associations.items() if v[0] > 0]))
```

And wouldn't you know, it worked!

## Part 2

This part is the main reason why I spent 4 days to write the blog post from Day 16 to Day 19. The problem introduces a new entity that can explore the graph, which is affectionately chosen to be an elephant, and cuts the amount of time we have to explore the nodes to 26 units of time.

To save you the trouble from thinking about it: no, a double for-loop in DFS doesn't work. Well, it would, if you run the program for 16 hours (actual calculations), but it is definitely not the intended solution.

Of course, it didn't stop me from trying:

```python
def dfs(info_source_1, info_source_2, pressure, visited, important_nodes, distances_map, depth=0):
  source_1, time_1 = info_source_1
  source_2, time_2 = info_source_2

  if time_2 >= 26 and time_1 < 26:
    return dfs(info_source_2, info_source_1, pressure, visited, important_nodes, distances_map, depth+1)

  if time_1 >= 26 and time_2 >= 26:
    return pressure

  distances_1 = distances_map[source_1]
  distances_2 = distances_map[source_2]
  best_pressure = pressure

  for impt_node_1 in important_nodes:
    node_1, (point_pressure_1, _) = impt_node_1
    if node_1 in visited:
      continue

    new_time_1 = time_1 + distances_1[node_1] + 1
    new_visited = visited.copy()
    new_visited.add(node_1)

    if time_2 >= 26:
      new_pressure = pressure + point_pressure_1 * (26 - new_time_1)
      res = dfs((node_1, new_time_1), info_source_2, new_pressure, new_visited, important_nodes, distances_map, depth+1)
      if res > best_pressure:
        best_pressure = res
      continue

    for impt_node_2 in important_nodes:
      node_2, (point_pressure_2, _) = impt_node_2
      if node_2 in visited or node_1 is node_2:
        continue

      new_time_2 = time_2 + distances_2[node_2] + 1
      new_pressure = pressure + point_pressure_1 * (26 - new_time_1) + point_pressure_2 * (26 - new_time_2)
      new_visited_inner = new_visited.copy()
      new_visited_inner.add(node_2)
      res = dfs((node_1, new_time_1), (node_2, new_time_2), new_pressure, new_visited_inner, important_nodes, distances_map, depth+1)
      if res > best_pressure:
        best_pressure = res

  return best_pressure
```

While it worked for the example input, it doesn't work (i.e. doesn't finish within acceptable time) for the real input. This is because there are `15! * 14! = 114,000,816,848,279,961,600,000` possible combinations for the algorithm to run through.

So, what next? I tried BFS as well:

```python
def bfs(info_source_1, info_source_2, important_nodes, distances_map):
  q = Queue()
  p = Queue()

  q.put((info_source_1, info_source_2, 0, set(), 0, []))
  set_of_all_important_nodes = set([k for k, _ in important_nodes])
  found_pressure = 0
  found_depth = 999999

  while not q.empty():
    info_source_1, info_source_2, pressure, visited, depth, path = q.get()

    if depth > found_depth:
      break

    source_1, time_1 = info_source_1
    source_2, time_2 = info_source_2

    if time_2 >= 26 and time_1 < 26:
      source_1, source_2 = source_2, source_1
      time_1, time_2 = time_2, time_1
    elif time_1 >= 26 and time_2 >= 26:
      continue
    elif len(visited & set_of_all_important_nodes) == len(important_nodes):
      if pressure > found_pressure:
        found_pressure = pressure
        found_depth = depth

    distances_1 = distances_map[source_1]
    distances_2 = distances_map[source_2]
    best_pressure = pressure

    for impt_node_1 in important_nodes:
      node_1, (point_pressure_1, _) = impt_node_1
      if node_1 in visited:
        continue

      new_time_1 = time_1 + distances_1[node_1] + 1
      new_visited = visited.copy()
      new_visited.add(node_1)

      if time_2 >= 26:
        new_pressure = pressure + point_pressure_1 * (26 - new_time_1)
        q.put(((node_1, new_time_1), info_source_2, new_pressure, new_visited, depth+1, path))

      for impt_node_2 in important_nodes:
        node_2, (point_pressure_2, _) = impt_node_2
        if node_2 in visited or node_1 is node_2:
          continue

        new_time_2 = time_2 + distances_2[node_2] + 1
        new_pressure = pressure + point_pressure_1 * (26 - new_time_1) + point_pressure_2 * (26 - new_time_2)
        new_visited_inner = new_visited.copy()
        new_visited_inner.add(node_2)
        q.put(((node_1, new_time_1), (node_2, new_time_2), new_pressure, new_visited_inner, depth+1, path + [(node_1, node_2)]))

  return found_pressure
```

The BFS mechanism uses a gimmick to break out early, because I reasoned that beyond a certain depth, we approach diminishing returns. Needless to say, BFS worked on the example input, but not on the actual input, due to space complexity.

I went berserk and also implemented Dijkstra's to find the minimum spanning tree, but in hindsight, I have no idea what I was trying to accomplish with it.

Eventually, I gave up and went to bed. On and off, I would try my hand again, including attempting to use permutations to shuffle the order of valves to open, but again, due to space complexity, this was infeasible.

Finally, I decided to look for inspiration. Without looking at the solutions, I looked through the Reddit post, and found a post by [betaveros](https://www.reddit.com/r/adventofcode/comments/zn6k1l/comment/j0ffso8/?utm_source=share&utm_medium=web2x&context=3) (at time of writing, the top on the leaderboard), which contained a sentence that gave me the inspiration to settle on the answer: "one person first, then the same DFS for the other over all unopened valves".

If I may: "god damn it"! I've thought about this at one point, but my implementation was naive: I simply made one explorer explore half the list, and the other explorer explore the other half of the list. However, this failed because obviously, not _all_ possibilities were considered.

However, let's think about it another way. Assume I have 6 valves to open. If I were to open the valves alone, I may not be able to finish within the 26 measly minutes given to me. So, the whole point of teamwork is to split up the work. Hence, two explorers should open roughly 3 valves each. However, recall that once a valve has been opened, **it cannot be opened again**. Hence, all I need to do is to perform DFS on 3 valves, then change the actor to the other explorer, and perform DFS on the remaining 3 valves. Hence, instead of searching through `6! * 5!` possibilities, I am now at `6!` possibilities, which is definitely doable within human time.

Supersizing to the current problem, we now have an opportunity to restrict the problem to `15!` possibilities, which may be a huge number, but definitely much smaller than `15! * 14!` possibilities. Hence, the new DFS is implemented as such:

```python
def dfs(info_source_1, info_source_2, pressure, visited, important_nodes, distances_map):
  source_1, time_1 = info_source_1
  source_2, time_2 = info_source_2

  if time_1 >= 26 and time_2 >= 26:
    return pressure, path
  elif time_1 >= 26 or (len(visited) + 1 > len(important_nodes) // 2 and time_2 != 9999):
    return dfs(info_source_2, (source_1, 9999), pressure, visited, important_nodes, distances_map)

  distances = distances_map[source_1]
  best_pressure = pressure

  for impt_node in important_nodes:
    node, (point_pressure, _) = impt_node
    if node in visited:
      continue

    new_time = time_1 + distances[node] + 1
    new_visited = visited.copy()
    new_visited.add(node)

    new_pressure = pressure + point_pressure * (26 - new_time)
    res = dfs((node, new_time), info_source_2, new_pressure, new_visited, important_nodes, distances_map)
    if res > best_pressure:
      best_pressure = res

  return best_pressure
```

So, applying this diff (`<` is part 1, `>` part 2) to the part 1 solution, and running the program for roughly 20 minutes will give us the final result.

```diff
22,24c22,29
< def dfs(source, time, pressure, visited, important_nodes):
<   if time >= 30:
<     return pressure
---
> def dfs(info_source_1, info_source_2, pressure, visited, important_nodes, distances_map):
>   source_1, time_1 = info_source_1
>   source_2, time_2 = info_source_2
>
>   if time_1 >= 26 and time_2 >= 26:
>     return pressure, path
>   elif time_1 >= 26 or (len(visited) + 1 > len(important_nodes) // 2 and time_2 != 9999):
>     return dfs(info_source_2, (source_1, 9999), pressure, visited, important_nodes, distances_map)
26c31
<   distances = get_distances(source, associations)
---
>   distances = distances_map[source_1]
34,35c39
<     new_time = time + distances[node] + 1
<     new_pressure = pressure + point_pressure * (30 - new_time)
---
>     new_time = time_1 + distances[node] + 1
38c42,44
<     res = dfs(node, new_time, new_pressure, new_visited, important_nodes)
---
>
>     new_pressure = pressure + point_pressure * (26 - new_time)
>     res = dfs((node, new_time), info_source_2, new_pressure, new_visited, important_nodes, distances_map)
52c58,60
< print(dfs('AA', 0, 0, set(), [(k,v) for k, v in associations.items() if v[0] > 0]))
---
> important_elements = [(k,v) for k, v in associations.items() if v[0] > 0]
> distances_map = {k: get_distances(k, associations) for k in associations.keys()}
> print(dfs(('AA', 0), ('AA', 0), 0, set(), important_elements, distances_map))
```

----

# Day 17

Wha...? Is this Tetris?

## Part 1

Yeah, this is almost like tetris. Given a bunch of blocks, which are the horizontal line, cross, L-shape, vertical line and square, we are tasked to get the height of the tetris board after 2022 tetrominos sets on the board. The tetrominos follow a sequence of movements, which is our input; it looks something like this:

```
>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
```

`>` stands for right, and `<` stands for left. The sequence of movements repeats. The tetrominos themselves follow the standard set of rules, which are:

1. The tetrinome cannot hit the boundaries of the board (which is defined as width of 7 and height of infinity)
2. If the bottom of the tetrinome collides with any other settled tetrinomes, or the bottom of the board, settle the tetrinomes.

So, the sub-problems are:

1. Represent the tetrinomes, define procedures for movement;
    1. Moving left & right based on sequence
    2. Moving down after left & right
2. Figure out if the tetrinome has landed
3. Figure out maximum height of the board at the end of 2022 block landings

I decided to represent the tetrinome positions as a set of positions, and adjust the positions based on how the block is falling. So, the code is as follows:

```python
shapes = [[(0, 0), (1, 0), (2, 0), (3, 0)],
  [(1, 0), (0, 1), (1, 1), (2, 1), (1, 2)],
  [(2, 2), (2, 1), (0, 0), (1, 0), (2, 0)],
  [(0, 0), (0, 1), (0, 2), (0, 3)],
  [(0, 0), (1, 0), (0, 1), (1, 1)]]
offset = {
  '<': (-1, 0),
  '>': (1, 0)
}
shape_offset = 2
width = 7

sequence = open('input.txt', 'r').read().strip()
positions = set()

shape_i = 1
dropped = 0
current_block = [(x + shape_offset, y + 3) for x, y in shapes[0]]
board_max_y = 0
while dropped < 2022:
  for s in sequence:
    current_block = [(x + offset[s][0], y + offset[s][1]) for x, y in current_block]
    xs = sorted(current_block, key=lambda b: b[0])
    ys = sorted(current_block, key=lambda b: b[1])
    min_x, max_x = xs[0][0], xs[-1][0]
    min_y, max_y = ys[0][1], ys[-1][1]

    if min_x < 0 or max_x >= width or len(set(current_block) & positions):
      current_block = [(x - offset[s][0], y - offset[s][1]) for x, y in current_block]
    before_down_block = current_block.copy()
    current_block = [(x, y - 1) for x, y in current_block]

    if min_y <= 0 or len(set(current_block) & positions):
      dropped += 1
      positions |= set(before_down_block)
      board_max_y = max(positions, key=lambda x: x[1])[1]
      current_block = [(x + shape_offset, y + board_max_y + 4) for x, y in shapes[shape_i]]
      shape_i = shape_i + 1 if shape_i < len(shapes) - 1 else 0

    if dropped >= 2022:
      break

print(board_max_y + 1)
```

## Part 2

Ah yes, following the pattern we've seen in Day 16, we experience another expansion of the problem statement beyond what is reasonable to do with our original algorithm. Our goal now is simple: instead of getting the height at 2022 blocks, we want 1000000000000 (that's 12 zeros, which means this is 1 trillion). Obviously, not feasible.

Turns out, this problem can be boiled down into a simple sequencing problem. I began by hypothesizing that at _some_ point, there must be a pattern for height increments; there are a limited number of blocks, and a limited number of sequences. In logical hindsight, this is likely due to the pigeonhole principle - I'll reach a point where I'm going through the exact same blocks for the exact same sequences.

To confirm this experimentally, I inserted a print statement to figure out if this was true:

```python
  stats = dict()
...
    if board_max_y - new_max_y not in stats:
      stats[new_max_y - board_max_y] = 1
    else:
      stats[new_max_y - board_max_y] += 1

    if s_i % len(sequence) == 0: # on the actual input, this is (s_i + 1) % ...
      print(stats)
...
  print(stats)
```

where `s_i` is the index in the sequence.

I quickly realised that the pattern holds beyond the first statement; this implies that after a certain starting sequence, the sequence **started to repeat**, implying a predictable increase in height for a fixed increase in block drops.

In the code, I added a cheeky little comment that says the actual input would require me to change the condition to `s_i + 1`. Why?

Let's use the actual numbers: the sequence given in the example has 40 tokens, while the sequence given in the actual input has 10091 tokens. `s_i` is bounded from 0 to 39 in the example, while `s_i` is bounded from 0 to 10090 in the actual input. Hence, `s_i % len(sequence) == 0` is only true when `s_i` is any multiple of 40 in the example, while `(s_i + 1) % len(sequence) == 0` is true when `s_i` is only true when `s_i` is a multiple of 10090. This is not a co-incidence, because 40 and 10090 are divisible by the number of possible blocks in the context, 5 (also each number's greatest common factor).

Intuitively, this means that at `40` and `10090` sequences respectively, it encapsulates a multiple of block drops for all 5 bocks perfectly. Remember the pigeonhole principle? Let's say I have 20 pigeons and 10 holes. If we dictate each pigeon to always fly into adjacent holes, then necessarily, each hole must have 2 pigeons (without dictating the behaviour of the pigeon, we could have 1 hole with 19 pigeons). The same applies for this context; 40 sequences and 5 blocks, where each sequence will always apply to the next block in order, then necessarily, each block must have 8 sequences associated to it, always.

So, with sequences repeating every `40` or `10090` sequences, we can **bypass the need to simulate falling tetromines**, and just simulate height differences instead.

Okay, so we now have the theory. How do we translate this to practice?

Turns out, we are able to "shortcut" most of 1000000000000 block drops, by estimating as much as we can with just pure mathematics.

```python
estimated_height = int((1000000000000 - blocks_1) / blocks_difference) * repeat_height_difference
```

Where `blocks_difference` is the number of blocks dropped from a sequence of `40` to `80`, or `10090` to `20181`, and `repeat_height_difference` is the height difference between two repeating sequences. I will discuss how to get this later.

Then, we process the rest of the blocks using the sequences we derived:

```python
remaining_blocks = (1000000000000 - blocks_1) % blocks_difference

remaining_height = 0
height_epoch_x_i = 0
while remaining_blocks >= 0:
  remaining_height += height_epoch_x[height_epoch_x_i]
  remaining_blocks -= 1
  if height_epoch_x_i >= len(height_epoch_x) - 1:
    height_epoch_x_i = 0
  else:
    height_epoch_x_i += 1
```

where `height_epoch_x` is the height difference per sequence.

Now, how do we get `blocks_difference`, `height_epoch_x`, and `repeat_height_difference`? We know from experimental data that starting from a _certain number of blocks_, the sequence holds. Hence, we need to acquire this _certain number of blocks_, which is tied to the number of sequences processed (they need to be multiples of `40` or `10090`) and then continue simulating metronomes until we get the sequences from one multiple of `40` / `10090` to the next.

Hence, the code diff to get the final answer is as follows:

```diff
15a16
> # Figuring out the pattern
16a18
> s_i = 0
20,38c22,35
< while dropped < 2022:
<   for s in sequence:
<     current_block = [(x + offset[s][0], y + offset[s][1]) for x, y in current_block]
<     xs = sorted(current_block, key=lambda b: b[0])
<     ys = sorted(current_block, key=lambda b: b[1])
<     min_x, max_x = xs[0][0], xs[-1][0]
<     min_y, max_y = ys[0][1], ys[-1][1]
<
<     if min_x < 0 or max_x >= width or len(set(current_block) & positions):
<       current_block = [(x - offset[s][0], y - offset[s][1]) for x, y in current_block]
<     before_down_block = current_block.copy()
<     current_block = [(x, y - 1) for x, y in current_block]
<
<     if min_y <= 0 or len(set(current_block) & positions):
<       dropped += 1
<       positions |= set(before_down_block)
<       board_max_y = max(positions, key=lambda x: x[1])[1]
<       current_block = [(x + shape_offset, y + board_max_y + 4) for x, y in shapes[shape_i]]
<       shape_i = shape_i + 1 if shape_i < len(shapes) - 1 else 0
---
> runs = 2
> height_epoch_1 = []
> height_epoch_x = []
> si_1 = 0
> si_difference = 0
> blocks_1 = 0
> blocks_difference = 0
> while runs > 0:
>   s = sequence[s_i % len(sequence)]
>   current_block = [(x + offset[s][0], y + offset[s][1]) for x, y in current_block]
>   xs = sorted(current_block, key=lambda b: b[0])
>   ys = sorted(current_block, key=lambda b: b[1])
>   min_x, max_x = xs[0][0], xs[-1][0]
>   min_y, max_y = ys[0][1], ys[-1][1]
40,41c37,45
<     if dropped >= 2022:
<       break
---
>   if min_x < 0 or max_x >= width or len(set(current_block) & positions):
>     current_block = [(x - offset[s][0], y - offset[s][1]) for x, y in current_block]
>   before_down_block = current_block.copy()
>   current_block = [(x, y - 1) for x, y in current_block]
>
>   if min_y <= 0 or len(set(current_block) & positions):
>     dropped += 1
>     positions |= set(before_down_block)
>     new_max_y = max(positions, key=lambda x: x[1])[1]
43c47,86
< print(board_max_y + 1)
---
>     if runs == 2:
>       height_epoch_1.append(new_max_y - board_max_y)
>     else:
>       height_epoch_x.append(new_max_y - board_max_y)
>
>     if (s_i + 1) % len(sequence) == 0:
>       if runs == 2:
>         si_1 = s_i
>         blocks_1 = dropped
>       else:
>         si_difference = s_i - si_1
>         blocks_difference = dropped - blocks_1
>       runs -= 1
>     board_max_y = max(positions, key=lambda x: x[1])[1]
>     current_block = [(x + shape_offset, y + board_max_y + 4) for x, y in shapes[shape_i]]
>     shape_i = shape_i + 1 if shape_i < len(shapes) - 1 else 0
>
>   s_i += 1
>   if runs <= 0:
>     break
>
> # Use the pattern to engineer the simulation
> repeat_start_height = len(height_epoch_1)
> repeat_height_difference = sum(height_epoch_x)
>
> estimated_height = int((1000000000000 - blocks_1) / blocks_difference) * repeat_height_difference
> remaining_blocks = (1000000000000 - blocks_1) % blocks_difference
>
> remaining_height = 0
> height_epoch_x_i = 0
> while remaining_blocks >= 0:
>   remaining_height += height_epoch_x[height_epoch_x_i]
>   remaining_blocks -= 1
>   if height_epoch_x_i >= len(height_epoch_x) - 1:
>     height_epoch_x_i = 0
>   else:
>     height_epoch_x_i += 1
>
> height = int(estimated_height) + remaining_height + sum(height_epoch_1)
> print(height)
```

----

# Day 18

Lava and whatnot, oh my!

## Part 1

So, we have a bunch of positions that represent whether it contains lava particles. We want to find the surface area of the lava particles that make up the water droplets.

The problem, in programmer terms, is to accumulate (6 - number of edges) in all possible vertices of a graph.

This straight-forward problem is broken down into a graph problem, which can be traversed using any of the graph traversal algorithms. Each missing edge (i.e. 6 - number of edges) count towards a global variable, which represents the solution.

So, the solution is as follows:

```python
from queue import Queue
positions = set([tuple(map(lambda x: int(x), line.strip().split(','))) for line in open('input.txt', 'r').readlines()])

possibilities = [
  (1, 0, 0), (0, 1, 0), (0, 0, 1),
  (-1, 0, 0), (0, -1, 0), (0, 0, -1)
]
area = 0
visited = set()
q = Queue()

while len(visited & positions) != len(positions):
  d = (positions - visited).pop()
  visited.add(d)
  q.put(d)

  while not q.empty():
    x, y, z = q.get()

    for (dx, dy, dz) in possibilities:
      nx, ny, nz = x + dx, y + dy, z + dz
      if (nx, ny, nz) not in positions:
        area += 1
      elif (nx, ny, nz) not in visited:
        visited.add((nx, ny, nz))
        q.put((nx, ny, nz))

print(area)
```

## Part 2

Now, we want to only find the external surface area; meaning, any surface area that is surrounded by lava should not be considered. There were two main ways I could approach this:

1. From each of the positions of the nodes, if the node can reach `0` in any dimension, or the maximum of any dimension, then accumulate the area. Otherwise, don't accumulate the area.
2. I perform BFS on everything outside the positions of the nodes instead. If the node is touching a position, then count that into our area. As BFS can only explore connected nodes, this means that each time `q` is empty, we have explored one connected body. A connected body that touches `0` in any dimension or maximum in any dimension must be a liquid / water vapour. Otherwise, it is trapped gas between all the positions.

I decided to do step 2. So, I broke down the problem as:

1. Get complement of the set of lava-filled positions
2. Add padding of at least 1 in all dimensions
3. Run through DFS, add extra condition that if the node is touching a position, count into area.

So the diff to implement part 2 is:

```diff
2c2,16
< positions = set([tuple(map(lambda x: int(x), line.strip().split(','))) for line in open('input.txt', 'r').readlines()])
---
> from itertools import product
> positions = set()
> max_x, max_y, max_z = 0, 0, 0
> with open('input.txt', 'r') as f:
>   line = f.readline().strip()
>   while line:
>     pos = tuple(map(lambda x: int(x), line.split(',')))
>     max_x = max(max_x, pos[0])
>     max_y = max(max_y, pos[1])
>     max_z = max(max_z, pos[2])
>
>     positions.add(pos)
>     line = f.readline().strip()
>
> positions_prime = {(x, y, z) for x, y, z in product(range(-1, max_x + 2), range(-1, max_y + 2), range(-1, max_z + 2)) if (x, y, z) not in positions}
12,13c26,27
< while len(visited & positions) != len(positions):
<   d = (positions - visited).pop()
---
> while len(visited & positions_prime) != len(positions_prime):
>   d = (positions_prime - visited).pop()
16a31,32
>   isOutside = False
>   areaInContact = 0
19a36,38
>     if not (0 < x < max_x and 0 < y < max_y and 0 < z < max_z):
>       isOutside = True
>
22,24c41,44
<       if (nx, ny, nz) not in positions:
<         area += 1
<       elif (nx, ny, nz) not in visited:
---
>       if (nx, ny, nz) in positions:
>         areaInContact += 1
>
>       if (nx, ny, nz) not in visited and (nx, ny, nz) in positions_prime:
26a47,49
>
>   if isOutside:
>     area += areaInContact
```

----

# Day 19

Right, another entry down for the count. This day was quite similar to Day 16, because it involves doing a search on a space that is too large for comfort.

## Part 1

So, we have a blueprint, which are defined like so:

```
Blueprint 1:
  Each ore robot costs 4 ore.
  Each clay robot costs 2 ore.
  Each obsidian robot costs 3 ore and 14 clay.
  Each geode robot costs 2 ore and 7 obsidian.

Blueprint 2:
  Each ore robot costs 2 ore.
  Each clay robot costs 3 ore.
  Each obsidian robot costs 3 ore and 8 clay.
  Each geode robot costs 3 ore and 12 obsidian.
```

That allows us to build robots that gather resources to build even more robots to gather even more resources and so on. We start with 1 ore robot, and each robot will take 1 time unit to build, before it can contribute to our resource pool. Our goal is to calculate a score for each of the blueprint, and print out a linear combination of the score. The score is defined as the number of geodes the blueprint can possibly generate within 24 units of time.

Following the pattern I saw in Day 16, I quickly eliminated the typical graph search algorithms, and decided that DFS was the way to go. So, let's think about _when_ we want to call DFS.

A direct approach would be to, for every time unit, call DFS in an attempt to expend resources build every type of robot. Instinctively, I knew that this search space was too huge to consider.

Instead, we have to do a _good enough_ approximation of what _may_ happen. Here are some considerations:

- If I'm being optimal about my robot-building, which I must be due to time unit limitation, I _should_ only have enough resources to build a maximum of one robot per time unit. This eliminates the assumption that I could potentially concurrently build multiple robots in one go, as doing so would imply saving up for resources, which reduces contributions from the robots that could already have been built over the 24 time units.
- If, at any point of time, I am able to build a geode robot, I **must** do so, since I'm trying to maximize the number of geodes. I don't even have to consider building any other robot in that minute.
- If, at any point of time, I am able to build a obsidian robot, I _should_ do so, and ignore every other possibility. This assumption very rarely is false, as it is possible to save the resources for a greater benefit down the road. For this part, I assume the latter.
- If I am able to build a clay or ore robot, I should also consider saving resources for a greater benefit down the road.
- If, at any point of time, I have too much ore (which happens because DFS may keep choosing to save resources / build ore robots), I can completely prune the branch, because I am definitely getting further away from the objective.

The considerations help to reduce the search space into something that is completes within reasonable time (~10 minutes), and doesn't waste the CPU cycle looking at graphs that don't matter in the grand scheme of things. Putting together all the considerations, and some trial and error later, I end up with the following implementation:
```python
blueprints = list()
with open('input.txt', 'r') as f:
  line = f.readline().strip()
  while line:
    data = line.split(' ')
    blueprints.append((int(data[6]), int(data[12]), (int(data[18]), int(data[21])), (int(data[27]), int(data[30]))))
    line = f.readline().strip()

def dfs(blueprint, resources=(0, 0, 0, 0), bot_count=(1, 0, 0, 0), new_bot_count=(0, 0, 0, 0), minutes=0):
  best_quality = (resources[-1], resources, bot_count)
  if minutes > 24:
    return best_quality

  ores, clays, obsidians, geodes = resources
  ore_bots, clay_bots, obsidian_bots, geode_bots = bot_count

  ores += ore_bots
  clays += clay_bots
  obsidians += obsidian_bots
  geodes += geode_bots

  bot_count = tuple(map(lambda x: x[0] + x[1], zip(bot_count, new_bot_count)))

  minutes += 1
  if minutes == 24:
    return (geodes, (ores, clays, obsidians, geodes), bot_count)

  maximum_ores_required = max(blueprint[0], blueprint[1], blueprint[2][0], blueprint[3][0])
  if ores >= blueprint[3][0] and obsidians >= blueprint[3][1]:
    quality = dfs(blueprint, (ores - blueprint[3][0], clays, obsidians - blueprint[3][1], geodes),
      bot_count, (0, 0, 0, 1), minutes)
    if quality[0] > best_quality[0]:
      best_quality = quality
  elif ores >= blueprint[2][0] and clays >= blueprint[2][1]:
    quality = dfs(blueprint, (ores - blueprint[2][0], clays - blueprint[2][1], obsidians, geodes),
      bot_count, (0, 0, 1, 0), minutes)
    if quality[0] > best_quality[0]:
      best_quality = quality

    quality = dfs(blueprint, (ores, clays, obsidians, geodes), bot_count, (0, 0, 0, 0), minutes)
    if quality[0] > best_quality[0]:
      best_quality = quality
  else:
    if ores >= blueprint[1]:
      quality = dfs(blueprint, (ores - blueprint[1], clays, obsidians, geodes),
        bot_count, (0, 1, 0, 0), minutes)
      if quality[0] > best_quality[0]:
        best_quality = quality

    # snapback pruning: don't accumulate just ores
    if ores >= blueprint[0] and ores < 2 * maximum_ores_required:
      quality = dfs(blueprint, (ores - blueprint[0], clays, obsidians, geodes),
        bot_count, (1, 0, 0, 0), minutes)
      if quality[0] > best_quality[0]:
        best_quality = quality

    quality = dfs(blueprint, (ores, clays, obsidians, geodes), bot_count, (0, 0, 0, 0), minutes)
    if quality[0] > best_quality[0]:
      best_quality = quality

  return best_quality

accum_quality = 0
for i, blueprint in enumerate(blueprints):
  quality = dfs(blueprint)
  print(i, quality)
  accum_quality += (i + 1) * quality[0]
print(accum_quality)
```

## Part 2

The question increased the depth of the tree by adjusting the time unit from 24 to 32, and cutting down the number of blueprints to search to 3. This is a significant adjustment, as increasing tree depth exponentially increases the number of nodes to traverse. Hence, to create an algorithm that completes within reasonable time, we need to make even more assumptions of what _may_ happen.

Based on observations, there are only a _few_ blueprints with its highest number of geodes actually depending on saving resources whenever it could build an obsidian robot instead. Furthermore, by adjusting the time unit to 32, time can be wisely spent to build an obsidian robot, then providing resources to build a geode robot. Hence, the probability to save for resources when it could build an obsidian robot is decreased drastically.

As it turns out, the assumptions are true in our particular case, and removing just that one possibility from the previous algorithm allowed my solution to complete within human time (also, the scoring function changed as required by the question):

```diff
11c11
<   if minutes > 24:
---
>   if minutes > 32:
25c25
<   if minutes == 24:
---
>   if minutes == 32:
39,42d38
<
<     quality = dfs(blueprint, (ores, clays, obsidians, geodes), bot_count, (0, 0, 0, 0), minutes)
<     if quality[0] > best_quality[0]:
<       best_quality = quality
63c59
< accum_quality = 0
---
> accum_quality = 1
67c63
<   accum_quality += (i + 1) * quality[0]
---
>   accum_quality *= quality[0]
```

Is there a faster way? Probably, using heuristics and the other search algorithms. Do I want to implement it? Not this year!

----

# Day 20

This puzzle highlights the power of Python, because I don't have to think about huge numbers at all. Having done Days 17, 18and 20 in a row, I didn't bother trying to make the code run faster in Day 20; it's plenty fast compared to all the graph traversal I've done!

## Part 1

This problem is one of the easier ones among all of the challenges in AOC 2022 so far. Essentially, given a list of numbers, we need to rearrange the numbers such that each of the numbers are moved according to the value they represent. So, I solved it by:

1. Adding an identifier to every number (since the numbers provided are not unique)
2. Duplicating that list, calling it `mutable`
3. Referencing the original list, remove and insert the numbers in `mutable` based on the value of the int
4. Access the elements in the array based on procedure described by the solution as required, and calculate the answer

Here is code:

```python
movements = [(i, int(line.strip())) for i, line in enumerate(open('input.txt', 'r').readlines())]
mutable = movements.copy()
zero_tuple = tuple()
for i, m in movements:
  ind = mutable.index((i, m))
  mutable.pop(ind)

  new_ind = ind + m
  if new_ind > len(movements):
    new_ind %= len(movements) - 1
  elif new_ind <= 0:
    new_ind += len(movements) - 1
  mutable.insert(new_ind, (i, m))

  if m == 0:
    zero_tuple = (i, m)
zero_ind = mutable.index(zero_tuple)

print(mutable[(zero_ind + 1000) % len(movements)][1] +
  mutable[(zero_ind + 2000) % len(movements)][1] +
  mutable[(zero_ind + 3000) % len(movements)][1])
```

## Part 2

The only thing that changed were the input numbers. In Python, integers have no bounds. Then, we just perform the mixing operation 10 times, so the code is almost the same, but indented to fit the new for loop:

```diff
1c1
< movements = [(i, int(line.strip())) for i, line in enumerate(open('input.txt', 'r').readlines())]
---
> movements = [(i, 811589153 * int(line.strip())) for i, line in enumerate(open('input.txt', 'r').readlines())]
4,6c4,7
< for i, m in movements:
<   ind = mutable.index((i, m))
<   mutable.pop(ind)
---
> for _ in range(10):
>   for i, m in movements:
>     ind = mutable.index((i, m))
>     mutable.pop(ind)
8,13c9,16
<   new_ind = ind + m
<   if new_ind > len(movements):
<     new_ind %= len(movements) - 1
<   elif new_ind <= 0:
<     new_ind += len(movements) - 1
<   mutable.insert(new_ind, (i, m))
---
>     new_ind = ind + m
>     if new_ind > len(movements):
>       new_ind %= len(movements) - 1
>     elif new_ind <= 0:
>       new_ind += len(movements) - 1
>       factor = ((-new_ind) // (len(movements) - 1)) + 1
>       new_ind += (factor * (len(movements) - 1))
>     mutable.insert(new_ind, (i, m))
15,16c18,19
<   if m == 0:
<     zero_tuple = (i, m)
---
>     if m == 0:
>       zero_tuple = (i, m)
```

## Note on optimization

If I were to optimize this, it'll probably be similar to Day 17; since finite sequences are involved, repeats are bound to happen. However, the effort-to-result ratio is probably not worth it.

----

# Day 21

Today we have expression evaluations. It's quite a simple day, although I spent an embarrassing amount of time trying to figure out why my part 2 solution didn't work. More below.

## Part 1

We have a bunch of expressions that uses a bunch of symbols, like so:

```
root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32
```

All we have to do is to evaluate the value at `root`. Quite immediately, I got reminded of Prolog, which is a logic programming language that work on constraints. From what I know, Prolog does a depth-first search to obtain the results based on the constraints defined just like our input.

So, I thought about using trees to express the expression. However, I quickly realised that it would take too much effort; instead, a much faster way is probably to use a hash table, where the key is the symbol to be evaluated, and the value is the expression to evaluate.

Then, I jump to the root symbol, and recursively evaluate the constituent symbols until I figure out the final answer. Seems simple enough!

```python
operation_map = {
  '+': lambda x, y: x + y,
  '-': lambda x, y: x - y,
  '/': lambda x, y: x / y,
  '*': lambda x, y: x * y
}

expressions = {expr[0].rstrip(':'): expr[1:] for expr in [line.strip().split(' ') for line in open('input.txt').readlines()]}
def evaluate(expr):
  if expr[0].isdigit():
    return int(expr[0])
  else:
    return operation_map[expr[1]](evaluate(expressions[expr[0]]),
      evaluate(expressions[expr[2]]))

print(int(evaluate(expressions['root'])))
```

## Part 2

Part 2 redefines the problem:

- We now have an unknown within the symbols, which is `humn` (the original value of `humn` is now discarded)
- `root` is now `a = b`.

I decided to approach the problem mathematically, by performing inverse operations. Suppose we have an equation, `a = b op c`, where `a`, `b`, and `c` are unknowns. If we want to find the value of `b`, then we can rearrange the equation as: `b = a 'op c`. Then, we see how the new `root` fits into the picture; since `root` is essentially `lhs = rhs`, this implies that if:

```
root: a = c
a: x + y
c: b + z
```

If, again, we want to find `b`, then `b = c - z`, and since `root: a = c`, so `b = a - z`, therefore `b = x + y - z`. So this means we need to consider the following to change our equation:

1. Store associations in three different variants: `symbol = left op right`, `left = symbol op' right` and `right = symbol op' left`;
2. Figure out the rules for how to get `op'`;
3. For a target node, i.e. the variable `humn` in our case, find it within the associations `left = ...` or `right = ...`
4. Then, recursively evaluate `symbol` within the associations `left = ...` and `right = ...`. This will inverse our operators. For `right`, use the normal association `symbol = ...` to evaluate it.
5. If we find that `symbol` is root, we evaluate the other operand with the normal association `symbol = ...`. This essentially does the operation `left = right` within our evaluation.
6. Finally, once all the functions return, we end up with what `humn` must be.

The main assumption being made here is that the input cannot repeat a symbol twice (specifically, not the target symbol we are finding). Otherwise, the inverse operation approach here probably wouldn't work.

Next, let's figure out the rules to get `op`:

- If it's `+`, then transmute it to `symbol - operand`
- If it's `*`, then transmute it to `symbol / operand`
- If it's `-`, then transmute it to `symbol + right_operand` and `symbol _ left_operand`, where `_` effectively performs `left_operand - symbol`. I forgot to this, which caused me an hour or so to discover, as this does not affect the example input :sweat_smile:
- If it's `/`, then transmute it to `symbol * right_operand` and `symbol \ left_operand` where `\` effectively performs `left_operand / symbol`. I remembered this, but unluckily for me it wasn't used at all

With that out of the way, we can finally implement it:

```python
operation_map = {
  '+': lambda x, y: x + y,
  '-': lambda x, y: x - y,
  '_': lambda x, y: y - x,
  '/': lambda x, y: x / y,
  '*': lambda x, y: x * y,
  '\\': lambda x, y: y / x
}

expressions = dict()
left_expressions = dict()
right_expressions = dict()

with open('input.txt', 'r') as f:
  line = f.readline()
  while line:
    tokens = line.strip().split(' ')
    symbol = tokens[0].rstrip(':')
    expressions[symbol] = tokens[1:]
    
    if not tokens[1].isdigit():
      left, right = tokens[1], tokens[3]
      op = tokens[2]

      if op == '+':
        left_expressions[left] = [symbol, '-', right]
        right_expressions[right] = [symbol, '-', left]
      elif op == '-':
        left_expressions[left] = [symbol, '+', right]
        right_expressions[right] = [symbol, '_', left]
      elif op == '/':
        left_expressions[left] = [symbol, '*', right]
        right_expressions[right] = [symbol, '\\', left]
      else:
        left_expressions[left] = [symbol, '/', right]
        right_expressions[right] = [symbol, '/', left]
    line = f.readline()

def evaluate(expr):
  if expr[0].isdigit():
    return int(expr[0])
  else:
    return operation_map[expr[1]](evaluate(expressions[expr[0]]),
      evaluate(expressions[expr[2]]))

def evaluate_unknown(expr):
  if expr in left_expressions:
    (symbol, op, operand) = left_expressions[expr]
  else:
    (symbol, op, operand) = right_expressions[expr]
  if symbol == 'root':
    return evaluate(expressions[operand])
  return operation_map[op](evaluate_unknown(symbol), evaluate(expressions[operand]))

print(int(evaluate_unknown('humn')))
```

----

# Day 22

I'm embarrassed to say this, but I spent _way_ too long on this day, even though it should be fundamentally simple.

## Part 1

Part 1's context is actually quite simple; given a maze-like structure, navigate it with the instructions given in the input. If, during any point of navigation, the navigator falls off, then we warp the navigator to the other side of the map.

So, we just need to consider the min x, max x, min y and max y to do the problem. Here is a helpful snippet to print the boards being traversed:

```python
def print_board(x, y, direction, instruction):
  print('\033[2J')
  print('\033[H')
  print(x, y, direction, instruction)
  y_output = (y // 50) * 50
  for row in range(y_output, y_output + 50):
    for col in range(0, max(boundary_xs, key=lambda t: t[1])[1] + 1):
      if (col, row) == (x, y):
        if direction == 0:
          print('>', end='')
        elif direction == 1:
          print('v', end='')
        elif direction == 2:
          print('<', end='')
        elif direction == 3:
          print('^', end='')
      elif (col, row) in tiles:
        print(tiles[(col, row)], end='')
      else:
        print(' ', end='')
    print()
  print()
  print()
  sleep(0.1)
```

With some level of consideration to speed, I've decided to sacrifice my otherwise very free RAM to store way more dictionaries and lists than I really needed to. Here is how I solved it in the end:

```python
from functools import reduce

tiles = dict()
boundary_xs = list()
boundary_ys = list()
instructions = ''
start_pos = (-1, -1)
movement_map = [
  (1, 0),
  (0, 1),
  (-1, 0),
  (0, -1)
]
with open('input.txt', 'r') as f:
  line = f.readline().rstrip()
  y = 0
  while line:
    min_x, max_x = 999, -1
    for x, c in enumerate(line):
      if c != ' ':
        tiles[(x, y)] = c
        min_x = min(x, min_x)
        max_x = max(x, max_x)

        if x > len(boundary_ys) - 1:
          boundary_ys += (x - len(boundary_ys) + 1) * [(999, -1)]
        boundary_ys[x] = (min(boundary_ys[x][0], y),
          max(boundary_ys[x][1], y))

        if start_pos == (-1, -1):
          start_pos = (x, y)

    line = f.readline().rstrip()
    boundary_xs.append((min_x, max_x))
    y += 1
  instructions = reduce(lambda a, y: a[:-1] + [a[-1] + y] if y != 'L' and y != 'R' else  a[:-1] + [a[-1] + y] + [''], f.readline().strip(), [''])

direction = 0
x, y = start_pos
for i, instruction in enumerate(instructions):
  steps = int(instruction[0:-1] if i != len(instructions) - 1 else instruction)
  min_x, max_x = boundary_xs[y]
  min_y, max_y = boundary_ys[x]
  while steps:
    diff = movement_map[direction]
    new_x, new_y = x + diff[0], y + diff[1]
    while (x, y) in tiles and (new_x, new_y) not in tiles:
      if new_x > max_x:
        new_x = min_x
        continue
      elif new_x > min_x:
        new_x = new_x + diff[0]
      elif new_x < min_x:
        new_x = max_x
        continue

      if new_y > max_y:
        new_y = min_y
        continue
      elif new_y > min_y:
        new_y = new_y + diff[1]
      elif new_y < min_y:
        new_y = max_y
        continue

    if tiles[(new_x, new_y)] == '#':
      break
    else:
      x, y = new_x, new_y
      steps -= 1

  dirchange = instruction[-1] if i != len(instructions) - 1 else None
  if dirchange == 'L':
    direction -= 1
    if direction < 0:
      direction += len(movement_map)
  elif dirchange == 'R':
    direction += 1
    direction %= len(movement_map)

print(1000 * (y + 1) + 4 * (x + 1) + direction)
```

## Part 2

Now the maze becomes a cube. I first tried to map the co-ordinates to 3D, which was fine, until I realised I needed to find a way to fold the cube. After hours of thinking, drawing stuff till I went insane, I decided it was not worth the hassle.

So I decided to hard-code the relationship between each side in the cube. However, because there is no generalization, debugging exactly _what_ went wrong was ungodly. Thankfully, someone who has solved this beforehand provided a great cube visualizer that I used to debug my script, written by [nanot1m](https://nanot1m.github.io/adventofcode2022/day22/index.html). I also ran my script against another solution to check the output per instruction, only to find out that one of my functions that mapped the sides have the wrong offset.

So after roughly 5 hours, here is the final code:

```python
from functools import reduce
face_width = 50
tiles = dict()
boundary_xs = list()
boundary_ys = list()
instructions = ''
start_pos = (-1, -1)
movement_map = [
  (1, 0),
  (0, 1),
  (-1, 0),
  (0, -1)
]

cube_connection_operations = {
  1: [
    lambda x, y: (x + 1, y, 0), # 2
    lambda x, y: (x, y + 1, 1), # 3
    lambda x, y: (x - 50, 2 * 50 + (49 - y), 0), # 4
    lambda x, y: (0, (x % 50) + 3 * 50, 0) # 6
  ],
  2: [
    lambda x, y: (x - 50, 2 * 50 + (49 - y), 2), # 5
    lambda x, y: (99, 50 + (x % 50), 2), # 3
    lambda x, y: (x - 1, y, 2), # 1
    lambda x, y: (x % 50, 4 * 50 - 1, 3), # 6
  ],
  3: [
    lambda x, y: (2 * 50 + (y % 50), 49, 3), # 2
    lambda x, y: (x, y + 1, 1), # 5
    lambda x, y: (y % 50, 2 * 50, 1), # 4
    lambda x, y: (x, y - 1, 3), # 1
  ],
  4: [
    lambda x, y: (x + 1, y, 0), # 5
    lambda x, y: (x, y + 1, 1), # 6
    lambda x, y: (50, (49 - (y % 50)), 0), # 1
    lambda x, y: (50, 50 + x, 0), # 3
  ],
  5: [
    lambda x, y: (149, (49 - (y % 50)), 2), # 2
    lambda x, y: (49, 3 * 50 + (x % 50), 2), # 6
    lambda x, y: (x - 1, y, 2), # 4
    lambda x, y: (x, y - 1, 3), # 3
  ],
  6: [
    lambda x, y: (50 + (y % 50), 149, 3), # 5
    lambda x, y: (x + 100, 0, 1), # 2
    lambda x, y: (50 + (y % 50), 0, 1), # 1
    lambda x, y: (x, y - 1, 3) # 4
  ]
}

cube_toplefts = 6 * [None]
with open('input.txt', 'r') as f:
  line = f.readline().rstrip()
  y = 0
  while line:
    min_x, max_x = 999, -1
    for x, c in enumerate(line):
      if c != ' ':
        tiles[(x, y)] = c
        min_x = min(x, min_x)
        max_x = max(x, max_x)

        side_exist = False
        for topleft in cube_toplefts:
          if topleft is not None:
            tx, ty = topleft
            if tx <= x < tx + face_width and ty <= y < ty + face_width:
              side_exist = True

        if not side_exist:
          cube_toplefts[cube_toplefts.index(None)] = (x, y)

        if x > len(boundary_ys) - 1:
          boundary_ys += (x - len(boundary_ys) + 1) * [(999, -1)]
        boundary_ys[x] = (min(boundary_ys[x][0], y),
          max(boundary_ys[x][1], y))

        if start_pos == (-1, -1):
          start_pos = (x, y)

    line = f.readline().rstrip()
    boundary_xs.append((min_x, max_x))
    y += 1
  instructions = reduce(lambda a, y: a[:-1] + [a[-1] + y] if y != 'L' and y != 'R' else  a[:-1] + [a[-1] + y] + [''], f.readline().strip(), [''])

direction = 0
x, y = start_pos
for i, instruction in enumerate(instructions):
  steps = int(instruction[0:-1] if i != len(instructions) - 1 else instruction)
  min_x, max_x = boundary_xs[y]
  min_y, max_y = boundary_ys[x]

  cube_side = cube_toplefts.index(next(filter(lambda topleft: topleft[0] <= x < topleft[0] + face_width and topleft[1] <= y < topleft[1] + face_width, cube_toplefts)))

  while steps:
    diff = movement_map[direction]
    new_x, new_y = x + diff[0], y + diff[1]
    new_direction = direction
    topleft = cube_toplefts[cube_side]
    fell_out = not (topleft[0] <= new_x < topleft[0] + face_width and topleft[1] <= new_y < topleft[1] + face_width)

    if fell_out:
      new_x, new_y, new_direction = cube_connection_operations[cube_side + 1][direction](x, y)

    if tiles[(new_x, new_y)] == '#':
      break
    else:
      x, y, direction = new_x, new_y, new_direction
      cube_side = cube_toplefts.index(next(filter(lambda topleft: topleft[0] <= x < topleft[0] + face_width and topleft[1] <= y < topleft[1] + face_width, cube_toplefts)))
      steps -= 1

  dirchange = instruction[-1] if i != len(instructions) - 1 else None
  if dirchange == 'L':
    direction -= 1
    if direction < 0:
      direction += len(movement_map)
  elif dirchange == 'R':
    direction += 1
    direction %= len(movement_map)

print(1000 * (y + 1) + 4 * (x + 1) + direction)
```

It's ugly, the process is error-prone, I'm tired, this'll do. I've put off plans for this man!

----

# Day 23

Today's puzzle was much more manageable than the previous days! TGIF & Merry Christmas, amirite?

## Part 1

We follow our hero's journey as we now have to scatter elves in a fixed way. I spent roughly 30 minutes debugging why my code didn't work, only to realise that I haven't fully digested the specifications. Lesson learnt!

Okay so, we have an input like this:

```
....#..
..###.#
#...#.#
.#...##
#.###..
##.#.##
.#..#..
```

Each little hashtag moves according to a certain set of rules, which varies by the round number. The rules are:

1. Check all 8 positions to the side of hashtag. If no hashtag, do not move.
2. Check north, north-east, north-west. If there is another hashtag there, move on. Otherwise, attempt to move north.
3. Check south, south-east, south-west. Attempt to move south if no hashtag.
4. Check west, north-west, south-west. Attempt to move west if no hashtag.
5. Check east, north-east, south-east. Attempt to move east if no hashtag.
6. Otherwise, do not move.

"Attempt" to move can become "actually" moved if all hashtags end up having unique positions.

After every round of movement, steps 2 to 5 are rearranged to 3, 4, 5, 2. Essentially the first considered position is now the last considered position, and the second becomes the first, and so on.

With that, here's a helpful little function to print the board:

```python
def print_board():
  print('\033[0J')
  print('\033[H')
  pos_sorted_x = sorted(list(positions), key=lambda p: p[0])
  pos_sorted_y = sorted(list(positions), key=lambda p: p[1])

  min_x, max_x = pos_sorted_x[0][0], pos_sorted_x[-1][0]
  min_y, max_y = pos_sorted_y[0][1], pos_sorted_y[-1][1]
  for y in range(min_y, max_y + 1):
    for x in range(min_x, max_x + 1):
      if (x, y) in positions:
        print('#', end='')
      else:
        print('.', end='')
    print()
```

And here is the solution:

```python
positions = set()
with open('input.txt', 'r') as f:
  line = f.readline().strip()
  y = 0

  while line:
    for x, c in enumerate(line):
      if c == '#':
        positions.add((x, y))
    y += 1
    line = f.readline().strip()

def generate_decisions(rounds):
  decisions = dict()
  for (x, y) in positions:
    intersect_results = [
      len({(x - 1, y - 1), (x, y - 1), (x + 1, y - 1)} & positions) == 0,
      len({(x - 1, y + 1), (x, y + 1), (x + 1, y + 1)} & positions) == 0,
      len({(x - 1, y - 1), (x - 1, y), (x - 1, y + 1)} & positions) == 0,
      len({(x + 1, y - 1), (x + 1, y), (x + 1, y + 1)} & positions) == 0,
    ]
    if all(intersect_results):
      decisions[(x, y)] = (x, y)
      continue

    for iterator in range(len(intersect_results)):
      i = (rounds + iterator) % len(intersect_results)

      match i:
        case 0:
          if intersect_results[0]:
            decisions[(x, y)] = (x, y - 1)
            break
        case 1:
          if intersect_results[1]:
            decisions[(x, y)] = (x, y + 1)
            break
        case 2:
          if intersect_results[2]:
            decisions[(x, y)] = (x - 1, y)
            break
        case 3:
          if intersect_results[3]:
            decisions[(x, y)] = (x + 1, y)
            break

    if (x, y) not in decisions:
      decisions[(x, y)] = (x, y)
  return decisions

def count_empty():
  pos_sorted_x = sorted(list(positions), key=lambda p: p[0])
  pos_sorted_y = sorted(list(positions), key=lambda p: p[1])

  min_x, max_x = pos_sorted_x[0][0], pos_sorted_x[-1][0]
  min_y, max_y = pos_sorted_y[0][1], pos_sorted_y[-1][1]

  return ((max_x - min_x + 1) * (max_y - min_y + 1)) - len(positions)

rounds = 0
while rounds < 10:
  decisions = generate_decisions(rounds)
  hits = dict()
  new_positions = set()

  for result_pos in decisions.values():
    if result_pos in hits:
      hits[result_pos] += 1
    else:
      hits[result_pos] = 1

  for original_pos, result_pos in decisions.items():
    if hits[result_pos] > 1:
      new_positions.add(original_pos)
    else:
      new_positions.add(result_pos)
  
  positions = new_positions
  rounds += 1

print(count_empty())
```

## Part 2

Today's part two is the most natural out of all the part twos I have attempted in this year's AOC. Simply, we remove the boundaries of rounds, and figure out when all the hashtags run out of moves. So, basically, we just keep running until `positions == new_positions`. Hence, our diff would be:

```diff
61c61
< while rounds < 10:
---
> while True:
78d77
<   positions = new_positions
79a79,81
>   if positions == new_positions:
>     break
>   positions = new_positions
81c83
< print(count_empty())
---
> print(rounds)
```

It's not the fastest piece of code ever, but for the amount of effort I put in, being able to get the answer in five seconds is reasonable enough.

----

# Day 24

Today's puzzle is about path-finding, but on crack.

## Part 1

Let's examine an example:

```
#.######
#>>.<^<#
#.<..<<#
#>v.><>#
#<^v^^>#
######.#
```

The arrows, which are `>v<^` are moving obstacles in the board, moving towards the direction suggested by the arrows. These arrows can overlap, and warp around the board. Our goal is to perform path-finding through this board, and output the **shortest possible path**.

Okay, what's the best method? The first method I immediately thought of is to implement a path searching algorithm, and find the shortest path at every step. _However_, this is largely inefficient, because when there are as many obstacles as shown in the board above, then too much effort is put into re-calculating the path at every step due to obstacles to the path.

Instead, let's include the moving obstacles into our path search algorithm; at every step, we clone the board, move the obstacles, figure out the best next step, and repeat the process ad-infinitum until we reach the target position. To effectively do this, we must invent an algorithm that quickly converges to the target position, without searching unnecessary paths.

For this, I chose to use A\* search.

As usual, here is a useful function to print the board:

```python
def print_board(p, hs, steps):
  print('\033[2J')
  print('\033[H')
  print('Steps:', steps)
  px, py = p
  for y in range(0, height):
    for x in range(0, width):
      if ((x, y) == start_position) or ((x, y) == end_position):
        if (px, py) == (x, y):
          print('E', end='')
        else:
          print(' ', end='')
        continue

      if x % (width - 1) == 0:
        print('#', end='')
      elif y % (height - 1) == 0:
        print('#', end='')
      elif (x, y) == p:
        print('E', end='')
      else:
        hasDir = 0
        lastDir = '^'
        for c, _ in enumerate(directions):
          if (x, y, c) in hs:
            lastDir = directions[c]
            hasDir += 1
        if not hasDir:
          print('.', end='')
        elif hasDir > 1:
          print(hasDir, end='')
        else:
          print(lastDir, end='')
    print()
  print()
  sleep(0.1)
```

And here is the search implemented:

```python
from queue import PriorityQueue

directions = '>v<^'
directions_movement = [
  (1, 0),
  (0, 1),
  (-1, 0),
  (0, -1),
  (0, 0)
]
hurricanes = list()
width, height = -1, -1

with open('input.txt', 'r') as f:
  line = f.readline().strip()
  y = 0
  width = len(line)
  while line:
    for x, c in enumerate(line):
      if c in directions:
         hurricanes.append((x, y, directions.index(c)))
    line = f.readline().strip()
    y += 1
  height = y

def move(pos, isPlayer):
  x, y, c  = pos
  diff = directions_movement[c]
  x += diff[0]
  y += diff[1]

  if isPlayer:
    return (x, y, c)

  if x > width - 2:
    x = 1
  elif x < 1:
    x = width - 2

  if y > height - 2:
    y = 1
  elif y < 1:
    y = height - 2
  return (x, y, c)

start_position = (1, 0)
end_position = (width - 2, height - 1)
visited = set()
p = PriorityQueue()

p.put((0, start_position, hurricanes, 0))
found = False

while not p.empty():
  old_heuristic, (px, py), current_hurricanes, steps = p.get()
  steps += 1

  # move hurricanes
  new_hurricanes = list()
  for pos in current_hurricanes:
    new_hurricanes.append(move(pos, False))

  # attempt to move
  for c, direction in enumerate(directions_movement):
    x, y, _ = move((px, py, c), True)
    if (x, y) == end_position:
      found = True
      break

    if not (0 < x < width - 1 and 0 < y < height - 1):
      continue

    collides = False
    for (hx, hy, _) in new_hurricanes:
      if (x, y) == (hx, hy):
        collides = True
        break
    if collides:
      continue

    new_heuristic = steps + abs(end_position[0] - x) + abs(end_position[1] - y)
    if (x, y, steps) not in visited:
      p.put((new_heuristic, (x, y), new_hurricanes, steps))
      visited.add((x, y, steps))

  if found:
    print(steps)
    break
```

## Part 2

In part 2, I found a bug in my original code. If, right out of the gate, there is a hurricane blocking the path of the starting position, then the A\* search will return prematurely with no results:

```python
    if (x, y) == end_position:
      found = True
      break
```

To fix this, I simply check if the current position is the starting position; if it is, the subsequent block of code is executed, which has "stay still" as one of the possible actions to take.

Hence, after fixing the bug, I just move all of the path finding code to its own function, which will return the number of steps taken and the state of the board, and call it three times; once from start -> end, end -> start and start -> end again.

Here is the final diff:

```diff
46,49c46,67
< start_position = (1, 0)
< end_position = (width - 2, height - 1)
< visited = set()
< p = PriorityQueue()
---
> def astar(start_position, end_position, hurricanes):
>   visited = set()
>   p = PriorityQueue()
>
>   p.put((0, start_position, hurricanes, 0))
>   found = False
>
>   while not p.empty():
>     old_heuristic, (px, py), current_hurricanes, steps = p.get()
>     steps += 1
>
>     # move hurricanes
>     new_hurricanes = list()
>     for pos in current_hurricanes:
>       new_hurricanes.append(move(pos, False))
>
>     # attempt to move
>     for c, direction in enumerate(directions_movement):
>       x, y, _ = move((px, py, c), True)
>       if (x, y) == end_position:
>         found = True
>         break
51,52c69,84
< p.put((0, start_position, hurricanes, 0))
< found = False
---
>       if not (0 < x < width - 1 and 0 < y < height - 1) \
>         and (x, y) != start_position:
>         continue
>
>       collides = False
>       for (hx, hy, _) in new_hurricanes:
>         if (x, y) == (hx, hy):
>           collides = True
>           break
>       if collides:
>         continue
>
>       new_heuristic = steps + abs(end_position[0] - x) + abs(end_position[1] - y)
>       if (x, y, steps) not in visited:
>         p.put((new_heuristic, (x, y), new_hurricanes, steps))
>         visited.add((x, y, steps))
54,67c86,87
< while not p.empty():
<   old_heuristic, (px, py), current_hurricanes, steps = p.get()
<   steps += 1
<
<   # move hurricanes
<   new_hurricanes = list()
<   for pos in current_hurricanes:
<     new_hurricanes.append(move(pos, False))
<
<   # attempt to move
<   for c, direction in enumerate(directions_movement):
<     x, y, _ = move((px, py, c), True)
<     if (x, y) == end_position:
<       found = True
---
>     if found:
>       return current_hurricanes, steps
70,88c90,95
<     if not (0 < x < width - 1 and 0 < y < height - 1):
<       continue
<
<     collides = False
<     for (hx, hy, _) in new_hurricanes:
<       if (x, y) == (hx, hy):
<         collides = True
<         break
<     if collides:
<       continue
<
<     new_heuristic = steps + abs(end_position[0] - x) + abs(end_position[1] - y)
<     if (x, y, steps) not in visited:
<       p.put((new_heuristic, (x, y), new_hurricanes, steps))
<       visited.add((x, y, steps))
<
<   if found:
<     print(steps)
<     break
---
> start_position = (1, 0)
> end_position = (width - 2, height - 1)
> hurricanes, steps = astar(start_position, end_position, hurricanes)
> hurricanes, backsteps = astar(end_position, start_position, hurricanes)
> hurricanes, backbacksteps = astar(start_position, end_position, hurricanes)
> print(backbacksteps + backsteps + steps - 2)
```
----

# Day 25

There's only one part to this puzzle; and it's probably the most fun I had in a puzzle thus far!

Nothing like alternate number representations to end of the advent eh? In this puzzle, we have a bunch of alien-looking numbers, like so:

```
1=-0-2
12111
2=0=
21
2=01
111
20012
112
1=-1=
1-12
12
1=
122
```

We eventually find out that each of these numbers are in base 5, but with a twist (as there usually is); `-` and `=` represent -1 and -2 respectively, and the maximum digit that can be represented is 2. From a list of these integers, we need to sum it out, and return our sum in the same format.

Okay, so there are two subproblems:

1. Converting this integer representation to base 10;
2. Converting base 10 integers to this integer representation.

The first sub-problem is really simple. All we have to do is to sum the value represented by each digit position, negative and all that: so, for example, `1=-0-2` can converted to an integer by this method: `2 + (-1) * 5 + 0 * 5^2 + (-1) ^ 5^3 + (-2) ^ 5^4 + 1 * 5^5 = 1747`. In Haskell, this is a `foldr` zipped with the position of each digit, something like that:

```haskell
snafuToInt :: SNAFU -> Int
snafuToInt = foldr convert 0 . enumerate
  where
    convert (i, digit) acc = acc + (5 ^ i) * (snafuDigitToInt digit)
    enumerate xs = zip[(length xs) - 1, (length xs) - 2 .. -1] xs
```

where `SNAFU` is just a `String`, `snafuDigitToInt` converts `-=012` to an integer, like `-1, -2, 0, 1, 2`.


To approach the second sub-problem, we must understand that we are in a situation where we need to perform _differences_ to convert a normal base 10 integer to this strange version of an integer. Okay, what if it was to a normal base 5 integer? Normally, we would need to perform the following:

```
1747 % 5 = 2 (last digit is 2)

1747 / 5 = 349
349 % 5 = 4 (fourth digit is 4)

349 / 5 = 69
69 % 5 = 4 (third digit is 4)

69 / 5 = 13
13 % 5 = 3 (second digit is 3)

13 / 5 = 2
2 % 5 = 2 (first digit is 2)
```

As such, our base 5 reprsentation of 1747 is 23442. Now, let's think about how our number system changes things. If we now want to represent, say, 8, in normal base 5, that would be `1 * 5^1 + 3`. In our unique representation, it's `2 * 5^1 - 2`, whch means `2=`. We discover that the difference is actually just `1 * 5^1 + (3 - 5) + 5 = 2 * 5^1 - 2`, which is `2=`. Okay, what a bout a smaller number, like 6? That's `1 * 5^1 + 1` for both normal base 5, and our unique base 5 (`11`).

Hence, we find out that should our normal base 5 digit exceed `2`, we need to perform `(5 - digit)` on it, to get the correct representation at that point. But doing so will offset our answer by 5; how do we intend to fix that? Let's think about a larger number, say `74`. This is `2 * 5^2 + 4 * 5^1 + 4 * 5^0` in normal base 5. Using our logic above, to represent this in our unique number, we see that: `2 * 5^2 + (4 - 5) * 5^1 + (4 - 5) * 5^0` which is offset by `+ 5 * 5^1 + 5 * 5^0`, missing from the expression. Wait, isn't that just `5^2 + 5^1`? If we apply this back to the unique number expression, then: `3 * 5^2 + (4 - 5 + 1) * 5^1 - 1 * 5^0`, which is just `3 * 5^2 - 1` which is `5*5^2 + (5 - 3) * 5 ^ 2 - 1`, which is `5^3 - 2*5^2 - 1` which finally translates to `1=0-` in our special integer representation.

What this whole shtick implies is that we need to _carry over_ a 1 to the next significant digit, as long as our base 5 representation exceeds the maximum digit, 2.

With that finally out of the way, we can implement our logic:

```haskell
intToSnafu :: Int -> SNAFU
intToSnafu x = reverse $ convertDigits x 0 []
  where
    convertDigits num carry xs
      | num == 0 && carry == 0 = []
      | num' + carry > 2 = intToSnafuDigit (num' + carry - 5) : convertDigits num'' 1 xs
      | otherwise = intToSnafuDigit (num' + carry) : convertDigits num'' 0 xs
      where
        num' = num `mod` 5
        num'' = floor $ ((fromIntegral num) / 5)
```

I'm reversing the list because I don't want to do `++ []`, which increases my time complexity, however much that matters. Now that we have both of our conversion functions, we can finally do the problem, which is to sum all the numbers together in our special base 5 representation. The full code is as follows:

```haskell
import System.IO

type SNAFUDigit = Char
type SNAFU = String

snafuDigitToInt :: SNAFUDigit -> Int
snafuDigitToInt '=' = -2
snafuDigitToInt '-' = -1
snafuDigitToInt '0' = 0
snafuDigitToInt '1' = 1
snafuDigitToInt '2' = 2

intToSnafuDigit :: Int -> SNAFUDigit
intToSnafuDigit (-2) = '='
intToSnafuDigit (-1) = '-'
intToSnafuDigit 0 = '0'
intToSnafuDigit 1 = '1'
intToSnafuDigit 2 = '2'

snafuToInt :: SNAFU -> Int
snafuToInt = foldr convert 0 . enumerate
  where
    convert (i, digit) acc = acc + (5 ^ i) * (snafuDigitToInt digit)
    enumerate xs = zip[(length xs) - 1, (length xs) - 2 .. -1] xs

intToSnafu :: Int -> SNAFU
intToSnafu x = reverse $ convertDigits x 0 []
  where
    convertDigits num carry xs
      | num == 0 && carry == 0 = []
      | num' + carry > 2 = intToSnafuDigit (num' + carry - 5) : convertDigits num'' 1 xs
      | otherwise = intToSnafuDigit (num' + carry) : convertDigits num'' 0 xs
      where
        num' = num `mod` 5
        num'' = floor $ ((fromIntegral num) / 5)

main = do
  contents <- readFile "input.txt"
  let result = intToSnafu . sum . map snafuToInt $ lines contents
  print result
```

And with that, we've completed Advent of Code 2022, the first time ever I've done so!

<img src="/images/20221225_2.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Advent of Code 2022 Diagram"/>
<p class="text-center text-gray lh-condensed-ultra f6">Advent of Code Calendar 2022</p>

----

# Conclusion

I'll probably update this blog post for formatting, English and clearer explanations after Christmas, but I will not change the published date.

AOC has been a fun experience for me to hone my skills in a way that did not feel too overbearing, yet fun and engaging. The puzzles taught me a lot, highlighting things that I should improve on. In a nutshell, the lessons were:

- Fully understand the problem statement first
- Trust gut instinct on what _kind_ of data structure is needed
- Using gut instinct, pen down how the algorithm will be like. Don't try to fit everything in your head
- Test code regularly. If possible, test automatically

I hope to do AOC next year too, hopefully with less mistakes!

Merry Christmas and Happy 2023, folks.

Happy Coding,

CodingIndex
