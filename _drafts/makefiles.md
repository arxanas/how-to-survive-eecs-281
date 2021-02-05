---
layout: post
title: Making Makefiles
subtitle: Learn how to use Makefiles to automate any sort of task, including but
  not limited to compiling.
permalink: /making-makefiles/
---

I'm guessing the other TAs briefly exposed you to `Makefile`s in discussion and
then left you terribly confused. (Or not. I'll admit that I don't go to their
discussions, so I wouldn't know. But let's pretend, so that I have something to
talk about, that you want a refresher on how `Makefile`s work.)

In this document, we'll see how to construct a `Makefile` from the bottom up,
and have it do useful things like compile our project and make a submit archive.
On the way there, you'll also get to see me struggling to use the verb "make" so
as to avoid any confusion with the program.

# What is `make`?

So what exactly does `make` do? `make` is a *build system*. It automates
creating ("building") files from other files. Furthermore, it tries to be
efficient about it, and not build files when not necessary.

TODO: Is `make`, strictly-speaking, a build system?

How does it do this? We give `make` a set of rules that tells it how to build
file A from file B. If file B hasn't been changed, then `make` can assume that
we can use an old version of file A, and not have to rebuild it. This can save
us time when we have lots of files to be built.

A `Makefile` is just the file containing a set of rules to be fed to `make`.

# Why would I bother learning this silly program?

One convenient benefit is that we can use it to alias long commands to short
ones. We can say `make` instead of `g++ -std=c++11 *.cpp -o my-exe`. That's
typically enough for me to set up a `Makefile`, since it's just a couple of
lines.

The more important thing is that using a `Makefile` means we can avoid
rebuilding our entire executable (or whatever it is you're building), and
instead just rebuild the parts that have changed. This can save a huge amount of
time, since we only have to rebuild the things which have changed.

In industry-sized projects, it can take hours to complete a full build. For
example, this guy [takes two hours to finish a full build of
Chrome][chromium-build]. The Linux kernel can [take a couple hours to build as
well][linux-build], and it only gets longer from there.

  [chromium-build]: http://stackoverflow.com/q/9547371/344643
  [linux-build]: http://askubuntu.com/q/182890/136133

## The C++ build process

To speed up C++ compilation, we'll want to individually compile each source file
into an *object file*. Then, once they're all generated, we can *link* them
together and produce an executable. The advantage of this is that if we change
only one source file, then we have to generate only one object file, which is
way faster than compiling the whole codebase.

<aside class="aside-info"><p>

So what's a linker? It's the thing that links together object files in this way.
If you get a "linker error", then it means that there was an error that could
only be caught at link-time. (For example, if you didn't define a function body,
the compiler wouldn't know about it until it had examined every single object
file to be sure that it's really not there.)

</p></aside>

# Format of a Makefile

A `Makefile` is made up of any number of *rules*. A typical rule consists of the
following components:

  * **Target file**. This is the file that we are building.
  * **Prerequisites**. This is a space-delimited list of files that have to be
    present and up-to-date before trying to build the target. If they're not
up-to-date, `make` will rebuild them automatically (if it knows how to).
  * **Build rules**. These are the Unix commands to run to actually build the
    target file, given that we have all of the prerequisite files. One command
per line.

The rule is formatted like this in the file:

{% highlight make %}
my-target: prereq1 prereq2 ...
	build-my-target-step-1
	build-my-target-step-2
	...
{% endhighlight %}

<aside class="aside-warning"><p>

Each of the build rules <em>must</em> have a tab at the beginning of the line.
Spaces won't work.

</p></aside>

You'll have multiple rules that look like this in your `Makefile`. You can list
them out in any order; the one thing to keep in mind is that running `make` with
no arguments will run the first target in the file. We'll discuss this later.

# Making the submit archive

Let's start with a simple example. To submit to the autograder, you have to
submit a `.tar.gz` file. We could run `tar` every time we wanted to do this, but
that's a pain, and worse, we might forget some files.

Before you read further, think about the parts of a rule and try to identify
what the target, prerequisites, and the build rules would be.

<div class="blank-page"></div>

Done? Let's go over it. The target is the thing we want to end up making. In our
case, let's call it `submit.tar.gz`. So our rule so far looks like this:

{% highlight make %}
submit.tar.gz:
{% endhighlight %}

What are its prerequisites? Or, if you like to think about it this way, when
would we need to regenerate our submit file? We need to regenerate the submit
file when any its contents change. This includes our header and source files,
and also our `Makefile` and test cases.

We say that `submit.tar.gz` *depends on* our headers, sources, and `Makefile`.

<aside class="aside-info"><p>

The terms "prerequisite" and "dependency" are interchangeable. Just to remind
you, these are the things that we need to be present and up-to-date before we
can start making the target file.

</p></aside>

Let's add them to our rule:

{% highlight make %}
submit.tar.gz: main.cpp main.h test-1.txt Makefile # And anything else...
{% endhighlight %}

So with this rule, we're telling `make` that it's clear to try building the
`submit.tar.gz` file as long as `main.cpp`, `main.h`, etc. 1) exist on the file
system, and 2) are up-to-date. For now, we'll ignore the idea of `main.cpp` and
friends being up to date or not. Just pretend that they are.

The last thing we need to do is to tell `make` how to actually create
`submit.tar.gz` given all of these files. We'll invoke the `tar` command to do
that.

{% highlight make %}
submit.tar.gz: main.cpp main.h test-1.txt Makefile # And anything else...
	tar -czf submit.tar.gz main.cpp main.h test-1.txt Makefile
{% endhighlight %}

<aside class="aside-warning"><p>

We're promising `make` that after it's done running all of our commands,
`submit.tar.gz` will be created and up-to-date. `make` won't verify that you
actually did, so if you didn't actually build `submit.tar.gz`, you would
probably have issues.

</p></aside>

Try putting this content in your `Makefile`, in the same directory as whatever
source files you might have. Then, in that same directory, run `make
submit.tar.gz` from the command line. It should run the `tar` command the first
time, and skip it each time after that. Try editing one of your files and run
`make submit.tar.gz` again --- it should regenerate your `.tar.gz` file.

# Variables in Makefiles

Writing out all of our submission files is difficult to maintain if we want to
update them. So we can write this instead:

{% highlight make %}
SUBMIT_FILES = main.cpp main.h test-1.txt Makefile

submit.tar.gz: $(SUBMIT_FILES)
	tar -czf $(SUBMIT_FILES)
{% endhighlight %}

But this still means that we have to update this file whenever we add files. We
can use `make`'s convenient `wildcard` function to address this:

{% highlight make %}
SUBMIT_FILES = $(wildcard *.cpp *.h test-*.txt) Makefile

submit.tar.gz: $(SUBMIT_FILES)
	tar -czf $(SUBMIT_FILES)
{% endhighlight %}

Basically, `make` replaced `$(wildcard ...)` with the actual contents of running
the `wildcard` function. Take care to note that the word `Makefile` was after
the function call. The end result is that `$(SUBMIT_FILES)` is a space-separated
list of files.

TODO: Do these qualify as functions or macros?

<aside class="aside-info"><p>

The asterisk in <code>test-*.txt</code> means that the pattern will match any
files starting with <code>test-</code> and ending with <code>.txt</code>. This
is called a <a href="http://en.wikipedia.org/wiki/Glob_(programming)">glob
pattern.</a>

</p></aside>

There are plenty more convenient built-in functions for `make`. CAEN uses GNU
make, which is perhaps the most featureful variant.

TODO: Verify that GNU make is actually the version on CAEN.

# Using `make submit` instead of `make submit.tar.gz`

Oftentimes, when we design a `Makefile`, we want to provide convenient names for
targets. If we want to make it so that we can type `make submit` instead of
`make submit.tar.gz`, we'll use a *phony target*. Just add these lines to your
Makefile:

{% highlight make %}
.PHONY: submit
submit: submit.tar.gz
{% endhighlight %}

A phony target is a special target that we use to provide these convenient
command names. By marking it as phony, `make` won't try to look for a file
called `submit` which it needs to generate; instead, it understands that this is
just the name of a command that you're using.

If you don't get why we need phony targets, don't worry about it too much for
now --- it's not all that important for actually writing a `Makefile`. Just
pretend phony targets are convenient aliases to be able to run `make foo`
instead of `make my-long-filename`.

The first line tells `make` that `submit` is a phony target. The second line
means that the command is complete once we've built all of its prerequisites,
which would just be `submit.tar.gz` here. That means that in order to `make
submit`, `make` just needs to ensure `submit.tar.gz` is up-to-date.

<aside class="aside-info"><p>

If you don't mark `submit` (or other convenience command) as phony,
<code>make</code> will start behaving very strangely if there actually is a file
called <code>submit</code> in the directory. It may refuse to build at all, or
build unnecessarily every time, and you may not notice until you've already
wasted a submit or two.

</p></aside>

# Building an executable

Submit archives are fun and all, but they don't help us actually build programs.
Suppose we want to build an executable `foo` from the source files `foo.cpp` and
`foo.h`. What might the targets, dependencies, and build rules be? Try writing
out the full rule yourself before proceeding.

<div class="blank-page"></div>

The target is the executable we're trying to build, `foo`. Its prerequisites are
the source files, and the build rules are invocations of our compiler. So here's
our build rule:

{% highlight make %}
foo: foo.cpp foo.h
	g++ foo.cpp -o foo
{% endhighlight %}

One mistake you might have made is to try to have compiled header files (so
something like `g++ foo.cpp foo.h -o foo`). **Don't compile header files!**
Header files are mostly a convenience for declaring things (especially for when
we want to use multiple object files), and should not be included in the
compiler input directly. (The preprocessor will paste the contents of the header
file for you, anyways.)

<aside class="aside-info"><p>

TODO: Explain what compiled header files are for.

</p></aside>

TODO: Make sure to mention how `make` will regenerate the prerequisites as well!
This is crucial to using `make` effectively.

# Syncing with CAEN

TODO: Decide whether this section is important enough to actually keep. It might
be better as an addendum.

TODO: Explain what this command does --- syncs from your local computer to CAEN.
This might not even be applicable for the majority of the audience.

The `make sync` command will also be a phony target, since we don't actually
want to create a file called `sync`.

At this point, you should consider whether or not there are any dependencies for
this command. Yes, there are dependencies --- whatever source files you have.
You wouldn't want to do a re-sync if none of your files have changed.

However, the `sync` command doesn't actually produce any files, and
since `make` checks the modified time of the build result and compares the
modified time of any prerequisites, it doesn't have any way to know whether a
`sync` actually needs to be done.

  [ssh-aliases]: {{ site.baseurl }}/dealing-with-caen

TODO: See if there's a permalink option.

Fortunately, there's the `rsync` command available on most Unixes which will
intelligently sync directories for us, and only transfer changed files. This
means that our command is just this (assuming we have a `caen` SSH alias, as
described in [this article][ssh-aliases]):

{% highlight make %}
.PHONY: sync
sync:
	rsync -avz --delete . caen:project-dir/
{% endhighlight %}

<aside class="aside-warning"><p>

The <code>--delete</code> flag means that <code>rsync</code> will delete any
extra files in the target directory, leaving the target directory an exact copy
of the source directory. Be careful when doing this. If you don't want this
behavior, omit the <code>--delete</code> flag.

</p></aside>
