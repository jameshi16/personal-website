---
title: Running an embedded executable in Python
date: 2023-10-08 22:51 +0100
published: true
tags: [python, fun]
categories: [python, fun]
---

Good morning! :coffee:

Suppose a hypothetical situation where you gained access to a Python REPL on
some server, somewhere. The REPL is artificially limited such that you have no
access to any file or networking.

Given that you are in a REPL, you can theoretically write any program you want;
however, you are lazy to write such a program, and instead wish to run an
arbitrary executable. After running some REPL commands, like:

```python
>>> import sys
>>> sys.version
'3.10.12 (main, Jun 11 2023, 00:00:00) [GCC 11.4.0]'
>>> sys.platform
'linux'
```

You realize the following:

- The system is running > Python 3.3 (more importantly, > Python 3.8); and
- It's running on Linux

As someone who knows how to code, surely you can whip up a script that would
can execute any arbitrary binary file even under these conditions, right?

----

# Executing an arbitrary executable

On Unix and Windows, Python supports an executable, as long as a file path is
specified. This is typically done with the following recipe:

```python
import os
os.execv("/bin/echo", ["-e", "hello world"])
```

The code above causes the `/bin/echo` to replace the current process
immediately and prints "hello world". After `/bin/echo` quits, so does Python.

Great, problem solved, right? Unfortunately, the oddly specific constraints
stated above has explicitly denied access to files, which includes the
`/bin/echo` executable.

Okay, so maybe we include the executable as part of the script instead. Since
we know that the REPL runs on Linux, we spin up a Docker container, and begin
experimenting.

First, we get the `/bin/echo` program as bytes:
```python
>>> data = open('/bin/echo', 'rb').read()
>>> data
b'\x7fELF\x02\x01\x01\x00...'
```

Backslashes looks really scary, so lets convert it to a Base64 encoded string:

```python
>>> import base64
>>> data_str = base64.b64encode(data)
>>> data_str
b'f0VMRgIBAQAAAAAAAAAAAAMA...'
```

Great, let's copy the whole string and keep it in our clipboard for now.

Next, we whip up a script, and write:

```python
import os
import base64

bin_file = base64.b64decode(b'f0VMRgIBAQAAAAAAAAAAAAMA...')
os.execv(bin_file, ['-e', 'hello world'])
```

And the run the program, and oh...

```
Traceback (most recent call last):
  File "your_file_here.py", line 1, in <module>
ValueError: execv: embedded null character in path
```

# execv and paths

Turns out, even with all the bytes of the executable, you can't just run it;
Python's `os.exec*` series of functions only support executables specified as
paths.

_Well..._

That statement is only half-true. As of Python version 3.3, the `os.execve`
[official Python
documentation](https://docs.python.org/3/library/os.html#os.execl) supports a
_file descriptor_.

> According to [this StackOverflow
> answer](https://stackoverflow.com/a/5256705), a _file descriptor_ is an entry
> created by the OS when a resource (e.g. file or sockets) is opened. This
> entry stores information about the resource, which includes how to access it.
> On Windows, this is also known as a _handle_.

The file descriptors on Unix can be found in `/proc/<pid>/fd`, where `<pid>` is
the process ID of the current process. Each file descriptor is represented by
an integer.

Okay, but why is this important? Because the standard streams, i.e. _standard
input_, _standard output_ and _standard error_ all have their own file
descriptors, which are 0, 1, and 2 respectively.

Notably, those standard streams _definitely_ don't occupy disk space; the file
descriptor to these standard streams simply represent the concept of those
streams ([StackOverflow](https://stackoverflow.com/a/3511816)). Even though the
files `/dev/stdout`, `/dev/stdin`, and `/dev/stderr` exist, they actually point
to `/proc/self/fd/<0/1/2>`, which is basically `/proc/<pid>/fd/<0/1/2>`, the
file descriptors in question.

In some sense, you can say that these streams exist in-memory (they're
technically buffered there, according to [this Quora
post](https://www.quora.com/What-does-it-mean-to-buffer-or-stdin-stdout-and-stderr)).

Now, answer me this: what happens if I pass `os.execve` a _file descriptor_
pointing to a resource that has executable content?

The theoretical answer: we can execute things.

# Exploring the theoretical answer

Let's run an experiment on a computer we have full access to.

We create two files; `redirect.py`, which basically redirects the standard
input to standard output, and `execute.py`, which spawns the `redirect.py`
subprocess, then attaches pipes to the standard output of `redirect.py`.

`execute.py` will write the Base64 string to `redirect.py`, and `redirect.py`
will respond with the raw bytes.

> We have to do it this way, because `sys.stdin.read()` reads _strings_ instead
> of bytes, which causes issues when trying to pass an entire executable. With
> `sys.stdout.buffer.write()`, we can write raw bytes into the standard
> output. Since we hijack `execute.py` with pipes, we can also receive raw
> bytes from `redirect.py`.

`redirect.py`:

```python
import base64
import sys

r = base64.b64decode(sys.stdin.read())
sys.stdout.buffer.write(r)
sys.stdout.flush()
sys.stdout.close()
```

In `execute.py`:

```python
import os
import subprocess

bin_file = b'f0VMRgIBAQAAAAAAAAAAAAMA...'
process = subprocess.Popen(['python', 'redirect.py'], stdin=subprocess.PIPE, stdout=subprocess.PIPE)

process.stdin.write(bin_file)
process.stdin.close()

os.execve(process.stdout.fileno(), ['-e', 'hello world'], {})
```

Giving a quick whirl, we see... oh...

```
Traceback (most recent call last):
  File "execute.py", line 10, in <module>
    os.execve(process.stdout.fileno(), ['-e', 'hello world'], {})
PermissionError: [Errno 13] Permission denied: 5
```

Looking at this
[AskPython](https://www.askpython.com/python/examples/handling-error-13-permission-denied)
article, it seems like this error happens when:
- File doesn't exist;
- Concurrent reads by another program;
- Permissions error

Given that we're using one of the standard streams, surely the file descriptor
points to something that actually exists; and given standard streams are
exclusive to processes, we couldn't have concurrent reads.

Hence, the only logical explanation stems from us receiving a permissions
error. _However_, that conclusion is relatively ill-conceived - how do we
assign permissions to a pipe?

After calling `os.stat` on both the `process.stdout.fileno()` file descriptor
and a normal executable file descriptor, we discover that there are indeed
indicators on the file mode that differentiates a stream to an actual file on
the system.

In fact, it is possible to use `os.chmod` to change `process.stdout.fileno()`'s
file mode, but that will _still_ not yield a working result.

So, end of the road? Can't be done? Not quite.

# In-memory files

We have just established that we _need_ files; the operating system has to
understand that the file descriptor points to a resource that is _meant_ to be
a file.

This would mean that creating a temporary file would work; however, since we
don't have write access to the filesystem, as constrained by above, we can't do
that. Instead, we simply create a file in memory.

But how?

If we look carefully under the Linux kernel manual, under the `sys/mman.h`
header file, we see that there is an interesting function by the name of
`memfd_create`. Here is a [link to that
manpage](https://man7.org/linux/man-pages/man2/memfd_create.2.html). The
manpage describes that:

- An _anonymous file_ is created; this function returns a file descriptor that points to it
- It _behaves_ like a normal file
- This file lives on the RAM

And wouldn't you know it, Python's `os` module has a `memfd_create` function!

Here's the plan:

1. We create an in-memory file and obtain a file descriptor
2. We write the bytes of the Base64 string into the in-memory file
3. We seek to the start of the file
4. We send the file descriptor over to `os.execve` and we're off the races!

Here is the final script:

```python
# script.py
import base64
import os
import sys

bin_file = base64.b64decode(b'f0VMRgIBAQAAAAAAAAAAAAMA...')

in_mem_fd = os.memfd_create("bin_name", os.MFD_CLOEXEC)
os.write(in_mem_fd, bin_file)
os.lseek(in_mem_fd, 0, os.SEEK_SET)
os.execve(in_mem_fd, ['-e', 'hello world'], {})
```

Finally, running the script will net us the result we were expecting:

```shell
$ python3 script.py
hello world
```

----

# Conclusion

What are the implications of this? For starters, you can embed any kind of
executable into a Python script. In the case of a malware, the script can
download any random executable from the internet, and run it without leaving a
file trace on your computer.

With enough trickery, the script can also hijack standard input and standard
output of the embedded executable, with the UI being indistinguishable from
just running the executable directly.

On a lighter note, you can, in theory, package your entire suite of
applications into a single Python script. It isn't feasible in production,
sure, but you can rest well knowing that it is indeed, _possible_.

Nevertheless, I hope this little fun adventure was entertaining to read. Until
next time!

Happy Coding,

CodingIndex
