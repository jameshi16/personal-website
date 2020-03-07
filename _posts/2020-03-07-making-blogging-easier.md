---
title: Making blogging easier
date: 2020-03-07 16:00 +08:00
categories: [fluff]
tags: [fluff]
published: false
---

My blog is built with Jekyll and hosted on GitHub Pages. This takes care of my hosting environment, and makes blogging much easier. However, while convenient, blogging is still frankly a pain. This is due to the following reasons:

1. Date issues. My blog posts usually take longer than a day to complete. This means updating the dates (and image file names) everytime I decide to work on a blog post; this gets quite irritating especially on a 20+ images blog post like my tutorial. 
2. Images. I don't particularly like to do any image editing when making my blog posts, unless I have to. What I usually do is I resize the images via HTML. Since I adjust the size of the images alot, it also explains why I don't have a stylesheet for images, since they are all slightly different. When you have lots of images like I do in my [Tutorial: ESP32 to AWS IoT to AWS DynamoDB](https://codingindex.xyz/2019/06/22/mqtt-aws-iot-dynamodb-part-1/) blog post, it becomes a royal pain.
3. Boilerplate. As mentioned in the previous point, I resize my images with HTML. As such, I keep a HTML template for images and captions, so that I can just paste them in and carry on with blogging. However, I'm lazy and would like a tool to insert the images for me, prompting me for the image source, alt text and caption automatically, instead of navigating to the relevant attributes and modifying them manually.
i. Publicizing. In particular, whenever a new blog post is published, I want it to be publicized on Twitter.

I really like to blog, and I want to continue blogging. However, these issues introduce friction and extra cognitive load when I'm blogging, so I would like to reduce that as much as possible. So, let's solve them. With tools. Written in Ruby. Because while most of these problems can be solve with bash scripting and easier commands, I like to make life harder. 

# Overall architecture

On the surface, these seem like a simple set of tools. However, I made them as complicated as possible and wrote unit tests for them. These blogging tools use a complex architecture in the backend, and took me over a few weekends to come up with a MVP. There are three main components in each tool:

- Line Processors
- Handlers
- The tool interface itself

TODO: Maybe attach a diagram here

## Line Processors

TODO: Line Processor diagram

Line Processors receive a single line to do work on. At the end of its work, it returns a line. When writing line processors, I generally only try and perform a single action. For example, `date_metadata_line_processor.rb` will generate a new date metadata line if it encounters an old date metadata line. There are some exceptions to this rule, which can be observed in `image_date_line_processor.rb`, which will not only generate new dated names for images, but also actually rename the physical images themselves.

Being able to split up Line Processors make the code a little cleaner than if they're all cluttered in the handler, which most likely would have made handlers a nightmare to read.

## Handlers

Handlers is the heavy-lifting class, and will do tool-specific work. What does not differ from each handler class is its `handle` function, so that one tool can perform a pipeline of handlers should the need arise (for example, the image tool will need to scan the file for image information, then eventually save new image information when the user is done interacting with it).

## The tool interface itself

This can come in the form of a CLI tool, or a GUI tool.

# Date Issues

The date issues I have in particular are:

- Updating the date metadata for each blog post
- Updating the image file names for each blog post
- Renaming the images with new dates
- Renaming the blog post with new dates

This is made easier with the `tools/update_dates.rb` script written for the express purpose of updating these dates. To use this tool, ensure that your working directory is in `tools/`, and follow the usage:

```
Usage
./update_dates.rb <path to blog post>
Changes the date of the blog post
```

Let's say I have a blog post, with the path `_posts/2019-12-25-christmas-is-for-nerds.md`, and one of the images I reference in the blog post would have the path: `images/20191225_1.png`. If I `cd tools/`, then run `./update_dates.rb ../_posts/2019-12-25-christmas-is-for-nerds.md`, then all the resulting files would be: `_posts/current-date-christmas-is-for-nerds.md` and `images/currentdate_1.png`, with all the metadata and references within the blog post updated.

# Image Issues

My images all come with captions, and are not easy to update, especially when there are 30 different images in one blog post. Furthermore, my images are sequences, like `20191225_1.png`, and renaming new images to fit this scheme introduces unnecessary cognitive load. Since Markdown doesn't support resizing photos with CSS styles, and adding a caption to each image, I created HTML templates, and used them for a while:

```html
<img src="source" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="alttext"/>
<p class="text-center text-gray lh-condensed-ultra f6">Caption</p>
```

I want to automate this. In short, I would like an easier way to:

- Append images
- Swap images
- Modify captions

Just to make life easier when performing image operations, I decided to use a GUI, so that the user (me) can see exactly what image they're replacing or captioning for. It goes without saying that GUI is one of the components that are difficult to write a unit test for, so to maximize test coverage, all the GUI was made to do is to perform the necessary operations to: (i) display image and captions, (ii) allow editing of captions, (iii) save, replace, and goto the next image. Other components such as actually writing to the blog post with the new changes are done in the backend.

The GUI framework used is `GNOME2`, with `Ruby-GNOME2` bindings. I considered using `tk`, but finding out that I needed `tcl` gave me second thoughts, as I wanted these tools to (almost) be a plug-and-play solution to all the machines I use - just run `sudo apt install ruby build-essential && gem install bundler && bundle install` and off to the races I go.

## HTML and Line Processing

HTML is a multi-line markup language, meaning that a single element in HTML can span multiple lines. However, I don't see myself needing to use multiple lines for images and captions, and so I won't be making special arrangements for multi-line HTML.

However, should you find the need to do so, please open a PR or an issue for the blogging tools. One method to achieve multi-line HTML parsing while still using the Line Processor interface would be to identify the start of a tag, and collect lines until the end of the tag is reached. Then, `nokogiri` can be used to parse the resulting string block.

## Captions

A small context: `ImageCaption` is a Data Transfer Object (DTO) that contains the image URL, the alt-text for the image, and the captions used for the image. `ImageCaptionBuilder` is a builder class that can take in the parameters required for `ImageCaption` in different calls, allowing the caller to build a `ImageCaption` object slowly, instead of instantiating it immediately.

Captions are surrounded by paragraph tags, i.e. `<p></p>` tags. This makes collision with an unintended paragraph tag very likely. To solve this problem, captions are only considered such if it directly succeeds an image a line later.

This can be done in two ways:
1. Adding a function in the `ImageCaptionBuilder` to check for stages when trying to add a caption; only at the stage after `alt-text` can a caption be added;
2. Adding a "last good line" variable in the appropriate processor; if a caption is tentatively detected, it needs to be one line after the "last good line" to be considered an actual caption.

I decided to go for option (2), as captioning-after-image seems like a specific enough logic to implement in line processors. I wanted to the DTOs and builders to contain as little logic as possible, considering that they deal with underlying data.

# Future Improvements to the tools

Line Processors should receive a signal at EOF. If an image without a caption is placed at the end of the file, it will not be processed, because the line processor will not be called again after loading the image into `ImageCaption`. Having an EOF callback, or parameter as part of `process` could be helpful to prevent this problem.

There are two parts of the code where the same set of actions are performed to copy the contents of a file, replacing only the lines necessary (`time_updater_handler.rb` and `set_image_captions_handler.rb`). I can probably abstract that writing action to a `WriteFileHandler`, and let it be inherited by both files.
