---
title: Bash Scripting Essentials
date: 2020-03-07 23:00 +08:00
categories: [utility, linux]
tags: [linux]
published: true
---

By no means am I a professional at bash scripting. That being said, I've done some pretty cool projects with just pure bash scripting, like [ContainerTop](https://github.com/jameshi16/ContainerTop), a container-based desktop environment launcher, and [ungoogled-chromium-builder](https://github.com/jameshi16/ungoogled-chromium-builder) to let my private server build ungoogled chromium for my laptops.

At work, I also write a bunch of utility aliases and functions to aid my work - these are my "commonly utilized" techniques and commands condensed into a blog post. This article is written as a "cheatsheet", hopefully to serve as a quick reference for myself; though, if you find it useful, you can bookmark this page!

NOTE: When writing bash scripts, make sure to run `chmod +x ./relative/path/to/script` at least once to flag the script as an executable.

# Table of Contents

1. [Shebang](#shebang)
2. [Redirects](#redirects)
3. [Background](#background)
4. [Subshells](#subshells)
5. [Variables](#variables)
6. [Exit on error](#exit-on-error)
7. [Return code](#return-code)
8. [Ending a block](#ending-a-block)
9. [Arrays](#arrays)
10. [Finding files](#finding-files)
11. [Replacing strings](#replacing-strings)
12. [Removing columns](#removing-columns)
13. [Newlines are not preserved](#newlines-are-not-preserved)

# Shebang

Any executable file containing the "shebang" in its first line:

```bash
#!/bin/bash
```

Will cause the script to be executed by the specified executable, which also means the script needs to be in a language understood by those executables. Some common shebangs I've write are: `/usr/bin/ruby` and `/usr/bin/python3`, which uses the Ruby and Python interpretor for the script respectively. Most people publishing scripts for usage online use `/usr/bin/env ruby` and `/usr/bin/env python3` instead, allowing users with non-standard or different interpretor locations to use the scripts.

# Redirects

Redirects use the operators `<` and `>`. By default, inputs come from `STDIN` and outputs go to `STDOUT`, which are typically your terminal input and output respectively. This behaviour can be changed with `<` and `>`.

For example,
```bash
echo "hello" > file
```
Will write the word "hello" out to `file`, which is a normal file.
```bash
cat < file
```
Will read the word "hello" from `file`, which is the same file the "echo" has written "hello" to.

## Common use case: Log files

Redirects can let you log the outputs of commands:
```bash
cat /var/log/syslog 2>&1 > log
```
Whatever expression in front of `>` will produce outputs that go into the log file. `2>&1` instructs bash to redirect `STDERR`(2) to `STDOUT`(1). This is quite helpful for commands that don't typically output to log files.

# Background

The ampersand symbol at the back of a command will cause it to run in the background:
```bash
sleep 999 &
```
When a background command is executed within an interactive shell, you can switch back to it with `fg` and switch away from it with `CTRL+Z`. Use `ps` to view the processes currently running in the terminal session. For a terminal session with no background processes, you should see two items: `bash` itself, and `ps`.

# Subshells

Subshells are created with the following syntax:
```bash
$(echo "hi")
```
The results are assignable to a variable, but without protection, it can run arbitrary commands. Try this:
```bash
$(echo "echo oh no")
```
This will print `oh no` instead of `echo oh no`. Such arbitrary commands can be avoided by enclosing the subshell with quotes ("). This works because `$` is an escape cue for bash when interpreting strings.
```bash
VARIABLE="$(echo 'echo oh no')"
```

# Variables

Variables can be defined like this:
```bash
VARIABLE="hello"
```

It can be used with "$VARIABLE":
```bash
echo $VARIABLE
echo "$VARIABLE"
```
Both variants should print `hello`.

To inhibit printing, use single quotes ('): 
```bash
echo '$VARIABLE'
```
The line should print `$VARIABLE`.

# Exit on error

There are two ways to achieve this: (i) `set -e` and (ii) `|| exit 1`.

```bash
set -e
test -x thisfiledoesnotexist || exit 1
```

It is highly recommended to use the latter, as the behaviour is more well-structured and well-defined. `set -e` causes the shell to exit on error if _any_ subcommands return with an error (defined as non-zero return status), while `|| exit` only exits on that particular line. 

# Return Code

To know the last return code of a command, use `$?`.
```bash
echo "this should succeed"
echo "$?" # prints 0
```

Remember that `0` is success.

# Ending a block

Different control statements have different ending statements. Below show some examples.

```bash
if [[ -e "/var/log/syslog" ]]; then
	echo "congratulations, you have a system log"
fi
```

```bash
case "$VARIABLE" in
	7)
		echo "lucky seven"
	;;
	10|16)
		echo "my favourite number"
	;;
	42)
		echo "universe number"
	;;
	*)
		echo "nothing special"
	;;
esac
```

```bash
for NUMBERS in 1 2 3 4 5 
do
	echo "$NUMBERS"
done
```

# Arrays

Arrays can be defined like this:
```bash
ARRAY=(1 2 3 4 5 6)
echo "${ARRAY[@]}" # prints 1 2 3 4 5 6
echo "${ARRAY}" # prints 1
echo "${ARRAY[0]}" # prints 1
```

Turning a string of space-delimited strings into an array can be done with the following command (thanks to [this link](https://stackoverflow.com/questions/10586153/split-string-into-an-array-in-bash/13196466)):
```bash
IFS=" " read -r -a ARRAY <<< "1 2 3 4 5"
echo "${ARRAY[@]}" # prints 1 2 3 4 5
```

Use arrays in for loops like this:
```bash
for NUMBERS in ${ARRAY[@]}
do
	echo "$NUMBERS"
end
```

# Finding files

Files can be recursively found using the `find` command:
```bash
find . -name "*.js"
```

change `.` to a directory of your choice. The pattern defined by `-name` supports the metacharacters: `*`, `?` and `[]`, but only works for _filenames_, so a pattern of `a/b` cannot be used. Instead, use the `-prune` option to remove directories that should not be included in the search. (Thanks to [this](https://stackoverflow.com/questions/4210042/how-to-exclude-a-directory-in-find-command))

Use the `-prune` command to remove directories you are not interested in, like this:
```bash
find . -path "Documents" -prune -o -name "*.zip" -print
find . -type d \( .path dir1 -o -path dir2 -o path dir3 \) -prune -o -print
```

# Replacing strings

Strings can be replaced with the `sed` command (among other utilities):
```bash
echo "i think apples are great" | sed 's/apples/oranges/g'
```
It might sometimes be necessary to use the `-E` flag for `sed` when a more complicated regex is used. I typically use [regexr](https://regexr.com/) to build my Regex. The 's/' is a `sed` command that means "substitute", with the '/g' at the back representing "replace everything". The one page GNU `sed` manual can be found [here](https://www.gnu.org/software/sed/manual/sed.html), or obtained via the `man sed` command.

The escape character for `sed` is `\` (backslash).

# Removing columns

If you have text like this (you can get something like this with `git branch`):
```
> git branch
* master
  develop
  bug-fixes
```

You can make the output processable by removing the first two columns (which contain the asterisk) with:
```bash
git branch | colrm 1 2
```

Output:
```
master
develop
bug-fixes
```

# Newlines are not preserved

Say you have a string with newlines, like this: `"hello\nworld"`. If you assign it to a variable after processing like this:
```bash
VARIABLE="$(echo -e "hello\nworld")"
echo $VARIABLE
```
Your output would be `"hello world"`. Be aware of this issue when writing scripts; this can probably be mitigated by using `tr`:
```bash
echo $VARIABLE | tr ' ' '\n' | cat
```
Output:
```
hello
world
```

---

That should be all for now. I may occasionally pop by to update this page, but the permalink should still stay the same. Keep a bookmark :bookmark: if you found it useful!

Happy coding,

CodingIndex
