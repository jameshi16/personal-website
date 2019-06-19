---
title: Interview Experience
date: 2019-06-19 09:00 +08:00
published: yes
tags: [interview, code]
categories: [fluff]
---

Recently, I was interviewed for few internships in the same company. It so happened that these interviews are technically-inclined interviews, which menat whiteboard programming.

I was a little excited to do that at first, but I was not prepared to get spoonfed the answer as soon as I took too long to think. For context, my problem statement was this: "Find the next number, greater than the current number, for any number on a Binary Search Tree."

Looking at the problem, I decided that I could solve it with a simple traversal-based algorithm, which caused my interviewer to raise his eyebrow, questioning my programming experience I have developed over the years. Turns out, that was not the solution he had in mind; he thought of a solution which involved _both_ Binary Search Tree and Binary Search (a wonder why they share similar names, huh?).

Back then, I didn't really push to let my solution through, because he was the interviewer, and he dictated the interview room. Hence, when I took too long to solve the problem, he started to guide me by asking me to traverse the tree, insert the elements into a list, then use binary search, then add one to the pointer. Once I understood what he was doing, he asked me to only implement a simple binary search algorithm. However, when I returned home, I quickly wrote down his solution and compiled it; then, I wrote down what I would have wrote on the whiteboard if he didn't stop me, and it turns out, my solution would work as well. In fact, mine will have better time **and** space complexity, because his solution involves two algorithms: Binary Search Tree traversal, and Binary Search, while mine only does Binary Search Tree traversal. His solution requires an extra list, while mine doesn't, hence the claim for a better space complexity. However, in terms of the Big-O notation, we would (annoyingly) have the same complexity for both time and space. The full code for the interviewer and myself can be found [here](https://gist.github.com/jameshi16/8b2a6483ae2d304070fd35f5b4004ad1).

> Problem statement: Find the next number, greater than the current number, for any number on a Binary Search Tree

For the purposs of this blog post, I will trim away all the excess code. Have a look at the following snippet:
```cpp
int sorted[8];
int sorted_it = 0;

void traverse(Node* parent_node) {
	if (parent_node->left != nullptr)
		traverse(parent_node->left);

	*(sorted + sorted_it++) = parent_node->value;

	if (parent_node->right != nullptr)
		traverse(parent_node->right);
}

int binarySearchNext(int* list, int list_size, int element) {
	int *start = list, *end = list + list_size -1; 
	int* it;

	if (*end == element) //next element cannot exist
		return -2;

	while (true) {
		it = start + (end - start) / 2; //get middle everytime
		if (*it == element) {
			it++;
			break;
		}	

		if (*it < element)
			start = it;

		if (*it > element)
			end = it;

		if (it == start)
			return -1; //can't even find the element
	}

	return *it;
}
```
This was the interviewer's answer to the problem statement. To use this snippet, you will need to call `traverse(parent_node)`, and then `binarySearchNext(sorted, 8, element)`. We are using in-order traversal, and you can see that during the traversal, values get added into an array, making a sorted array. A binary search is then performed on the array, and when the element is found, we add one to the iterator, returning us the next number. As a reminder, a traversal in a Binary Search Tree has the time complexity of `O(n)`, and Binary Search has the time complexity of `O( log(n) )`. In terms of space complexity, the whole algorithm takes up `O(n)`.

With that, let's have a look at my possible answer:
```cpp
bool element_found = false;
Node* nextElementNode = nullptr; //answer will be here 

void traverse(Node* parent_node, int num) {
	if (parent_node->left != nullptr)
		traverse(parent_node->left, num);

	if (element_found)
		if (nextElementNode == nullptr)
			nextElementNode = parent_node;
		else return;

	if (num == parent_node->value)
		element_found = true;
	
	if (parent_node->right != nullptr)
		traverse(parent_node->right, num);
}

int findNextElement(Node* parent_node, int num) {
	traverse(parent_node, num);

	if (element_found && nextElementNode == nullptr)
		return -2;
	
	if (!element_found && nextElementNode == nullptr)
		return -1;

	return nextElementNode->value;
}
```

To use this snippet, you need to call `findNextElement(parent_node, element)`. If you look closely, `findNextElement` is simply a wrapper function around `traverse`, and tries to understand the output of the algorithm by inspecting `element_found` and `nextElementNode`. Hence, the bulk of the work is done on the `traverse` function. The difference between the `traverse` function in my snippet, versus the snippet representing the interviewer's answer, is that my traverse has a few extra lines of code, namely:
```cpp
	if (element_found)
		if (nextElementNode == nullptr)
			nextElementNode = parent_node;
		else return;
```
This small block of code will assign the node to itself whenever `element_found` is true, but `nextElementNode` is `nullptr`. This is strategically placed _after_ traversing the left side of the node and _before_ checking the current node with the supplied value, so that if `num` is the last traversed element in the left side of the tree, then the recursive function will return all the way up to the parent node, making the parent node the next number to `num`.

As you can see, this method only involves traversing, which hence makes the time complexity of the algorithm `O(n)` only. In terms of space complexity, my solution is also `O(n)`.

Some of the sharper ones among you realized something: `O(n)`? Wait, doesn't that make linear search on the constructing list the same space-time complexity as both of these overly complicated algorithms?

Yes.

Yes it does.

We don't do that here.

Although, you are right. A simple linear search, looking for the minimum of all the greater elements than the element we are searching for would have sufficed, and be as equally efficient.

Once again, the snippet is at this link: [https://gist.github.com/jameshi16/8b2a6483ae2d304070fd35f5b4004ad1](https://gist.github.com/jameshi16/8b2a6483ae2d304070fd35f5b4004ad1).

Do try and correct me if I'm wrong on any part of this blog post, because, I have no idea what I'm actually doing. All I know is that my algorithm is a strong contender to the algorithm he suggested.

I have another interview coming up soon, so you can probably expect a blog post from that too :new_moon_with_face:.

Until then:

Happy Coding,

CodingIndex 
