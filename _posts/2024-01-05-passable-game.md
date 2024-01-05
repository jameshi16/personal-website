---
title: I tried to make another game...
date: 2024-01-05 15:49 +0000
categories: [game]
tags: [game, godot]
published: true
---

Happy New Year! :fireworks: How has everyone been?

Ah yes, I can already hear the scorn and disdain of some of you wondering where I've been all this time. Short answer: I
got lazy. Long answer: I have _a lot_ to do, but I'm also procrastinating. Man, I swear, it's probably a comedic routine
at this point to start my blog posts with some kind of excuse.

Anyways, you've read the title right; I tried to make another game!

<img src="/images/20240105_1.gif" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="untitled game"/>
<p class="text-center text-gray lh-condensed-ultra f6">untitled game | Source: Me</p>

> Note: Skip to [Day 1](#day-1) for the actual blog content.

Table of contents:

1. [Prelude - The story thus far](#prelude---the-story-thus-far)
2. [Day 1](#day-1)
3. [Day 2](#day-2)
4. [Day 3](#day-3)
5. [Epilogue](#epilogue)
6. [Conclusion](#conclusion)

# Prelude - The story thus far

Now, if you've ever read any of my blog posts, you'd know that I've _tried_ making a game before, with a deadline to
boot. It was called [Failed Game]({% post_url 2020-10-06-failed-game %}), and was made for my buddy
[ModelConverge](https://modelconverge.xyz/). It was a massive failure, with me spending eons trying to get the exact
movement I wanted, fixing size mismatches, writing a "manager", etc. Absolutely horrendous time management.

Surely, I have been polishing my skills to create a game that can captivate players for a gamejam, right? I definitely
should have improved since 2020!

Nope, I've not touched game development since then because I was traumatized by how little I got done.

Fast forward a few years (2023, around March), I started watching [Neuro-sama](https://www.twitch.tv/vedal987), and got
hooked the moment an Alternate Reality Game (ARG) was released. This somehow warmed my cold introverted heart, leading
me to create my first Twitch account, revive my old Discord account, and chat with random internet strangers about how
we hold this cute little AI and its creator in eternal reverence.

Here are some clips I hold dear to my hear:
- [Neuro and Vedal defuse bombs, but she progressively gets less helpful](https://www.youtube.com/watch?v=zkLU3-I0leU)
- [Evil x Neuro V3 sings In Hell We Live, Lament](https://www.youtube.com/watch?v=mhuQ_-UCbsg)
- [AI Evolved: Neuro-Sama Got A Lot Smarter After Vedal's Latest Upgrades](https://www.youtube.com/watch?v=-sr8m1L3HZ0)

The ARG is found [here](https://www.youtube.com/@_neurosama).

The Neuro-sama community is one of the most "at-home" I have felt for a while. Even during my lurking phase, I felt
nothing but awe; people were kind, talented, and helpful. To me, the fact that this community exists at all is nothing
short of a miracle.

So, out of love for the little AI and her creator, I began contributing by attempting the ARG (badly, I've been nothing
much but dead-weight). I had no other talents to contribute, can't do art, music, no bright ideas, and worst of all, I'm
not exactly a superstar programmer, especially compared to the AI's creator and most people in the
[#programming](https://discord.com/channels/574720535888396288/1071784467036913664) channel. Talk about a failure of
someone who literally runs a technology-related blog!

When the [Neuro-sama Birthday Game Jam](https://itch.io/jam/neurosama-birthday-game-jam) (28/12/2023 - 31/12/2023, 72
hours) rolled around during the subathon, I knew this was my only chance to get involved and actually do something. A
recap:

1. I have not made a full game before
2. I do not art
3. I do not music
4. I am at most a software engineer
5. Holding a conversation with a cucumber takes 90% of my energy for the day

I was hesitating - on one hand, I knew for a fact that I couldn't have created anything remotely playable even with
infinite time, much less in 72 hours. Plus, I actually have real-life work to complete, which I took up because I was
sure I wouldn't had any other commitments. On the other, I literally have no other chances to contribute to the
community. Furthermore, I've found myself working amazingly during tight deadlines, which is the case during my serial
hackathon days with [ModelConverge](https://modelconverge.xyz) and [nikhilr](https://nikhilr.io/).

Amidst tormenting myself with hesitation, the theme was announced on-stream by Neuro-sama to be "Lost & Found".
Pondering what I could create, I realized that I actually had ideas; more than anything, I had a **story** I wanted to
tell.

> While you're here, have a look at [my short stories]({% post_url 2023-05-31-short-stories %}). They're a ~~horrible~~
> collection of short stories I wrote expressing what I feel about our current world.

And so, I joined the Game Jam. Alone (I think I have crippling social anxiety).

----

# Day 1

## Concept

When I heard the theme "Lost & Found", my mind wandered to "oh, digging"! The player could dig up for lost items. Sound
good to me!

What else can you dig?

...

Graves.

## Story

I love games that can invoke emotions, because I don't normally feel them. Happiness is an overrated emotion, so I
decided to go for the sad route.

Tragedies are pretty difficult to convey; over-exploiting elements will cause the story to become stale, and become a
case of "oh, the author's at it again". For example, if I kept killing important characters left and right, the players
would become numb to that sensation, and the story may become predictable.

A tragedy is good when it is unexpected from the onset, but makes sense after the fact.

> Note: I have no idea what I'm talking about, this is all just personal takes on what makes a tragedy.

Digging for items? Digging for graves?

Let's add a plot twist. Let's make them dig their own grave.

<img src="/images/20240105_2.png" style="image-rendering: pixelated; max-width: 200px; width: 100%; margin: 0 auto; display: block;" alt="grave sprite"/>
<p class="text-center text-gray lh-condensed-ultra f6">Grave Sprite | Source: me</p>

## Core mechanics

After spying on some streams of people building their games, I set out to code the core mechanics first (this was a good
idea). The ideas are as such:

1. Levels randomly generate, with "landmarks" (things like small mushrooms, etc) scattered around the map
2. When a level begins, an overview map will be displayed with the locations of all the items and enemies.
3. Once the overview map is dismissed, the items will hide themselves.
4. Player goes around defeating enemies and collect items.

At this point, I have not figured out how to progress the story yet.

These set of core mechanics took a good total of 2 days to fully implement, including actually sleeping. Most of the difficulty
stemmed from me trying to figure out how Godot worked (never used a Game Engine in my life), what the heck nodes are,
and how they interact.

> I had the most trouble figuring out the difference between `Area2D`, `CharacterBody2D`, and `RigidBody2D`, which all
> have different callbacks and different uses. Figuring out the difference between area collision and body collision was
> a huge time sink :sweat_smile:

I used a walker for the level generation, which basically uses DFS and some parameters to randomly generate a walkable
path. This effectively means we have infinite level generation!

I also implemented enemies, with plans to implement different types of enemies (didn't end up doing it because of time).
To attack, the player would also use the shovel; hence, you couldn't dig and attack at the same time. The idea was to
challenge the player to knock the enemies back far enough before digging for items. Speaking of items, I implemented
various levels of items to add some variance to the game.

<img src="/images/20240105_3.png" style="max-width: 300px; width: 100%; margin: 0 auto; display: block;" alt="Low rarity item"/>
<p class="text-center text-gray lh-condensed-ultra f6">Amazing green ball with quality indicator | Source: me</p>

The most challenging part of this day was figuring out (for the life of me) how collisions with tilemaps worked;
because I had no idea. Even after setting the right tiles for collision on a `TileSet`, the player character couldn't
collide with the `TileMap` properly. It took a few hours, but I eventually figured it out and used a `CharacterBody2D`
on `floating` mode to introduce tile map collision physics.

HUD was also introduced on this day on another scene, adding HP and Stamina stats. I also eventually added other elements
to the HUD, like the score, and the timer indicating the amount of time left before the end of the level.

The second most challenging part of the day was navigation; it turns out, navigation only works on one layer (at the
time of writing) [based on this PR](https://github.com/godotengine/godot/pull/73018), and so I tore out my hair for no
reason trying to figure what in the world is going on. In the end, I resolved the navigation layer issue by using
background.

> At first, I wrote linear path-finding using the `Behaviour` design pattern. But, like, who has time for design
> patterns in a Game Jam?

To end the day, I used the path generated by the walker to also randomly place items.

----

# Day 2

## Core Mechanics

On this day, I implemented real bars to represent HP:

<img src="/images/20240105_4.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="bars"/>
<p class="text-center text-gray lh-condensed-ultra f6">Bars | Source: me</p>

And finally added stamina. When attacking, I figured the player should have some visual feedback that _something_ is
happening, so I decided to add slashes:

<img src="/images/20240105_5.gif" style="max-width: 200px; width: 100%; margin: 0 auto; display: block;" alt="slashes"/>
<p class="text-center text-gray lh-condensed-ultra f6">Slashes | Source: me</p>

I realized that not many people will understand the digging mechanic upon spawning on a random level, so I decided to
make a tutorial level:

<img src="/images/20240105_6.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="tutorial level"/>
<p class="text-center text-gray lh-condensed-ultra f6">Tutorial Level | Source: me</p>

Then, I put healthbars on enemies:

<img src="/images/20240105_7.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="enemy healthbar"/>
<p class="text-center text-gray lh-condensed-ultra f6">Enemy HealthBar | Source: me</p>
<!-- enemy healthbars -->

I also added some more quality-of-life mechanics, such as pressing a button to start a map, restarting a level, 
and a "level over" screen.

----

# Day 3

Honestly, at this point, I wasn't sure if I could complete the game. I saw some people in the community becoming
disheartened that they may not finish their game and dropping out; but I figured I continued anyway.

So, I sat my butt down on my chair and began working harder.

## Core Mechanics

I implemented "landmarks" - kinda like random small terrain objects that spawn on the foreground layer as memorization
helpers for the player.

<img src="/images/20240105_8.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="landmarks"/>
<p class="text-center text-gray lh-condensed-ultra f6">Landmarks | Source: me</p>

And... well, I think the core mechanics were done!

## Art

I suck at art. Nevertheless, I sat down and drew some sprites:

<img src="/images/20240105_9.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="sprites"/>
<p class="text-center text-gray lh-condensed-ultra f6">Sprites | Source: me</p>

And implemented them into the game.

## Story + Special Levels

Finally, I decided to actually flesh out the story. In my mind, I wanted to create something that _will_ invoke some
sort of emotion within the player. The rough idea of the story was "dig to recover memory fragments", and end off with
"here's the whole reason why you're in this mess". The rough storyboard was as follows:

1. The introduction will be at the tutorial. Make it as vague as possible, but a hint of "this isn't normal"
2. Players recover fragments of the story as they progress through the game
3. After `x` number of fragments, play a special level
4. After `y` number of fragments in total, play the ending special level

I ended up with 3 different special levels; I don't really want to spoil the story, so here is the overview of two
of the levels (the 3rd one is a story spoiler, so I won't show it):

<img src="/images/20240105_11.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="evil level"/>
<p class="text-center text-gray lh-condensed-ultra f6">Special Level 1 | Source: me</p>

<img src="/images/20240105_10.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="neuro level"/>
<p class="text-center text-gray lh-condensed-ultra f6">Special Level 2 | Source: me</p>

I would say I did pretty okay with the story. I'm not a professional writer, but I reckon it got the job done.

## Sound

At this point, I only had one hour left. So, I definitely couldn't be learning how to compose my own music in time;
instead, I searched online for a suitable track. I wanted a "lost in the forest" kinda vibe, but in the depressing tone,
which led me to find [this](https://chillmindscapes.itch.io/free-chiptune-music-pack-4-chillmindscapes) page, which has
a very fitting tune called "Goodbye Tales".

Adding an audio player, whipping out some quick code to play it on a loop, and I shipped it and called it a day.

----

# Epilogue

It was not a good game. The core mechanics were "complete", but definitely not polished. The art-style was absolute
garbage, and the music wasn't even mine.

The scoring mechanism to obtain fragments and reach special levels was completely broken, so I had to add a small note
to guide players towards obtaining them.

Many community members were able to notice the novice attempt at creating something resembling a game and gave me some
encouragement:

<img src="/images/20240105_12.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="encouragement"/>
<p class="text-center text-gray lh-condensed-ultra f6">Community Encouragement | Source: rating page</p>

Once again, my heart is warmed by the thoughtfulness of the community members.


## What could I have done better?

I could have done better on the following aspects:

- The code was horrendous; I could have written everything in the Model-View-Controller pattern; then maybe I wouldn't
  have spent so much time trying to add functionality
- Bugfixes (especially scoring)
- Getting people to play test
- Getting collaborators
- Using my own music

If I had collaborators, I would not need to spend so much time creating assets and focus on actually building a fun game. However,
I am also socially awkward, and have no idea how to properly do game development. Furthermore, I realize that if I
didn't work alone, I'd likely never have the chance to write the story I wanted to convey. After all, not everyone wishes
death upon someone/something they hold dear.

## What I found fun?

To be honest, the reviewing stage. I was given chance to rate other people's games, and found many gems. Take a look at
the [submissions page](https://itch.io/jam/neurosama-birthday-game-jam/entries) and try some yourself!

I'm a numbers-oriented person, and so I obsess over my analytics. This is partly the reason
why this website doesn't have Google Analytics - I'll probably compulsively obsess over it and get no work done.

However, that wasn't it. I also enjoyed watching people play my game (when they try their best to avoid the bugs, of
course). The fact that someone out there is experiencing the thing I've crafted, feeling the things I intended for them
to feel, and generally thinking it wasn't an abysmally horrible creation is something that keeps me ticking.

It reminded me of why I wanted to do technology in the first place; to create things used by others, creating as large
of an impact as possible. To this end, I've explored being a content creator (if you remember this you're a real one),
hosting large services, writing stories, joined companies to work on large stuff, and basically making many of my
impactful projects open-source. Most of them were misses, but I can at least exclaim that I tried at one point.

## Will I do it again?

Just like hackathons, the adrenaline really helped me realize I had skills I never thought I possessed. From rapid
learning via experimentation on Godot, to drawing sprites even though I failed art, to writing stories even though no
one ever reads mine. All of these (albeit almost non-existent) skills even helped me complete something as complicated
and scary as a game.

However, unlike hackathons, where I enjoyed working with like-minded individuals to get a product out that could
potentially solve industry-level problems, Game Jams are an expression of the team/individual's creativity.

I don't think I'll join just any game jam in the future. I _do_ need to care about it. The fact that the game jam was
centered around Neuro-sama helped a lot, because I already had a desire to give back.

However, I think I'll participate in the next Neuro-sama game jam, whenever that happens. I have many more stories I
want to tell with the Neuro-sama-verse characters. They'll probably not be very happy stories, though!

----

# Conclusion

You can play the game on [itch.io](https://vanorsigma.itch.io/neuro-game-jam-untitled-game), and the source code can 
be found [here](https://github.com/jameshi16/neuro-game-jam).

Again, it's not a very interesting game, so I hope you'll forgive me for not providing a better experience.

Nevertheless, it was a fun 72-hour game jam! Hopefully you had fun reading about my experience as much as I did
reminiscing about it.

Happy Coding

CodingIndex
