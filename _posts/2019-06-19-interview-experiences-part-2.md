---
title: Interview Experience - Part 2
date: 2019-06-19 20:00 +08:00
published: yes
tags: [interview, job, code]
categories: [fluff]
---

[Part 1](/2019/06/19/interview-experiences/)

Well; I told you - I would have had quite an experience and be able to make a blog post today.

I wanted to talk about one of the problems that was presented to me during the interview:
> How do you figure out if a linked list is incorrectly looping?

<img src="http://www.geeksforgeeks.org/wp-content/uploads/2009/04/Linked-List-Loop.gif" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="A looped linked list" />
<p class="text-center text-gray lh-condensed-ultra f6">Incorrect Looped Link List | Source: <a href="https://www.geeksforgeeks.org/detect-and-remove-loop-in-a-linked-list/">geeksforgeeks.com</a></p>

There are so many possible answers to this solution. I came up with a solution which involves using a `set` object to store all the pointers, and check with the set to ensure that there are no duplicates. It's a really bad algorithm, but I said it to answer the question. The interviewer's (his) solution was more interesting, and is something that I haven't encountered before - do keep in mind that I don't indulge myself into algorithms in my diploma course and free time, because I'm more focused in actually trying to do something than to do it well.

Anyway, his algorithm was like this:
1. Create two pointers, `Ptr1` and `Ptr2`;
2. Make `Ptr1` and `Ptr2` point at the same element;
3. `Ptr2` will advance two steps per iteration, and `Ptr1` will advance one step per iteration;
4. If any of the two pointers hit `NULL`, then the algorithm proves that there are no loops in the linked list;
5. `Ptr1` and `Ptr2` will eventually collide in the loop, if neither pointer has hit `NULL`, it signifies that there is a loop in the linked list.

This blew my mind a little bit, and after hitting `geeksforgeeks.org`, this 5 step proceedure I described was actually one part of the Flyod's Cycle detection algorithm (Flyod's Cycle detection algorithm is completed in the subsequent steps). What really displaced what little intellectual points I had left in me was the next part:

> How do you resolve the incorrectly looping linked list?

His algorithm was like this:
1. Set `Ptr2` back to the beginning of the linked list;
2. Let `Ptr1` and `Ptr2` go through the link list at the same speed, at one step per iteration;
3. Their first collision **will be** the beginning of the loop.

You may ask: wait, why is Step 3 true?

Let's say `Ptr1` travels `x` number of nodes within the linked list. This menas that `Ptr2` travelled `2x` number of nodes before it collides with `Ptr1`. What this also implies, is that if you were to let `Ptr1` travel another `x` number of nodes, it will collide with `Ptr2` again, as `x + x = 2x`, which is the same distance `Ptr2` has travelled. Now, think about the distances travelled by `Ptr1`: it needed `x` number of nodes to collide with `Ptr2` _from the start_ of the linked list, and, by travelling another `x` number of nodes, it _collides with `Ptr2` again_. This implies that if I were to have another pointer, called `Ptr3`, which travels at the same speed as `Ptr1`, with `Ptr1` starting at the collision position and `Ptr3` starting at the start, then `Ptr1`, `Ptr2` and `Ptr3` will collide at the same collision point. Meaning: the first collision point between `Ptr1` and `Ptr3` will signify the problematic node. If we were to make `Ptr1` travel through the whole loop again, checking the next node pointed by `Ptr1` to `Ptr3`, we can find the culprit causing the loop in the linked list, and route it to null.

In the above chunk of text, you realize that `Ptr2` is only used to prove that `Ptr1` and `Ptr3`'s first collision is the point where the loop begins. Hence, we can use `Ptr2` instead of `Ptr3`, saving us one memory location.

That's was interesting ain't it?

One more thing I learned during the interview is the existance of a trie:
<img src="https://upload.wikimedia.org/wikipedia/commons/b/be/Trie_example.svg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Trie tree"/>
<p class="text-center text-gray lh-condensed-ultra f6">A trie | Source: <a href="https://en.wikipedia.org/wiki/Trie">Wikipedia</a></p>

Which is helpful in search suggestions, especially if you have hundreds of thousands of such suggestions.

Well, I'll probably not get what I interviewed for; but that's fine. The experience taught me how it's like to be interviewed for my technical skills; and helped me come up with possible strategies to try before my next interview.

Good luck for your own interviews, if they're coming up!

Happy coding,

CodingIndex
