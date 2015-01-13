---
layout: post
title: Making Makefiles
subtitle: Learn how to use Makefiles to automate any sort of task, including but
  not limited to compiling.
permalink: /making-makefiles/
---
You've probably been briefly exposed to `Makefile`s in discussion and then left
no clue about how they work. Here, we'll discuss how to construct from the
bottom up a `Makefile` that does useful things like compiling, making a submit
archive, and syncing with CAEN.

`Makefile`s aren't useful only for C++ projects. They're usable in many other
contexts, such as the [asset pipeline in a web application][make-assets].

  [make-assets]: https://algorithms.rdio.com/post/make/

# Why use a Makefile?

For one, it means that we don't have to type long commands out whenever we want
to compile; instead, we just type `make` and that's it. (If that's enough for
you, feel free to skip the remainder of this section.)

But the more important part is that using a `Makefile` means we can rebuild only
the things which have changed, rather than having to rebuild our entire
application (or submission archive, or whatever else) whenever we try to build.
This can save a lot of time, since we only have to rebuild the things which have
changed.

In C++, this particularly applies to the generation of object files. Once you
have even a moderately-sized project, it can take a while to finish building it,
and you'll want to minimize that time. (In industry-sized projects, it can take
hours to complete a full build. For example, this guy [takes two hours to finish
a full build of Chrome][chromium-build]. The Linux kernel can [take a couple
hours to build as well][linux-build], and it only gets longer from there.)

  [chromium-build]: http://stackoverflow.com/q/9547371/344643
  [linux-build]: http://askubuntu.com/q/182890/136133

We can generate an object file for each source file, and then link them together
after all of the object files are up-to-date. This means that if you change a
single source file, only one object file will be changed, and you won't have to
recompile the majority of your codebase.

`make` gives us a convenient system to set up these sorts of builds. It
naturally models how many projects are set up, and it gives us a bunch of things
for free. For example, `make` can be set to run on multiple cores just by
passing the `-j` flag. You don't need to do anything special to make your build
parallelizable.

If you get used to using `make`, you can set up a build system for whatever
project you're working on --- and it doesn't have to be a C++ project --- which
will be more convenient and save you more time that manually building everything
yourself.

(I for one set up `Makefile`s for my Python and LaTeX projects, when
appropriate. It's not just a theoretically-possible thing. People actually do
it.)

# Format of a Makefile

A `Makefile` is made up of any number of *rules*. A rule consists of the
following components:

  * **Target file**. This is the file that we are building.
  * **Prerequisites**. These are any files that have to be present and up-to-date
    before trying to build the target. If they're not up-to-date, `make` will
rebuild them automatically (if it knows how).
  * **Build rules**. These are the steps to make the target, given that we have
    all of the prerequisite files.

The rule is formatted like this in the file:

{% highlight make %}
my-target: prereq1 prereq2 ...
	build-my-target-step-1
	build-my-target-step-2
	...
{% endhighlight %}

<aside class="aside-warning"><p>

Each of the build rules <i>must</i> have a tab at the beginning of the line. Spaces
won't work.

</p></aside>

# Making the submit archive

Let's start with a simple example. To submit to the autograder, you have to
submit a `.tar.gz` file. We could run `tar` every time we wanted to do this, but
that's a pain, and we might forget some files.

Before you read further, think about the parts of a rule and try to identify
what the target, prerequisites, and the build rules would be.

<div class="blank-page"></div>

Done? Let's go over it. The target is the thing we want to end up making. In our
case, this might be a file called `submit.tar.gz`. So our rule so far looks like
this:

{% highlight make %}
submit.tar.gz:
{% endhighlight %}

What are its prerequisites? Well, we want to regenerate our submit file whenever
any of the files inside it change. This includes our header and source files,
and also our `Makefile` and test cases. We say that `submit.tar.gz` *depends on*
our headers, sources, and `Makefile`.

<aside class="aside-info"><p>

The terms "prerequisite" and "dependency" are interchangeable. Just to remind
you, these are the things that we need to be present and up-to-date before we
can start making the target file.

</p></aside>

Let's add them to our rule:

{% highlight make %}
submit.tar.gz: main.cpp main.h test-1.txt Makefile # And anything else...
{% endhighlight %}

The last thing we need to address is the actual set of commands we need to use
to package `submit.tar.gz`.

{% highlight make %}
submit.tar.gz: main.cpp main.h test-1.txt Makefile # And anything else...
	tar -czf submit.tar.gz main.cpp main.h test-1.txt Makefile
{% endhighlight %}

# Variables in Makefiles

Writing out all of our submission files is difficult to maintain if we want to
update them. So we can write this instead:

{% highlight make %}
SUBMIT_FILES = main.cpp main.h test-1.txt Makefile

submit.tar.gz: $(SUBMIT_FILES)
	tar -czf $(SUBMIT_FILES)
{% endhighlight %}

<aside class="aside-warning"><p>

Variables in <code>make</code> have to be in the form <code>$(FOO)</code>. If
you omit the parentheses and have <code>$FOO</code>, <code>make</code> will
think that you want the variable <code>$F</code> followed by the literal string
<code>OO</code>.

</p></aside>

But this still means that we have to update this file whenever we add files. We
can use `make`'s convenient `wildcard` function to address this:

{% highlight make %}
SUBMIT_FILES = $(wildcard *.cpp *.h test-*.txt) Makefile

submit.tar.gz: $(SUBMIT_FILES)
	tar -czf $(SUBMIT_FILES)
{% endhighlight %}

<aside class="aside-info"><p>

The asterisk in <code>test-*.txt</code> means that the pattern will match any
files starting with <code>test-</code> and ending with <code>.txt</code>. This
is called a <a href="http://en.wikipedia.org/wiki/Glob_(programming)">glob
pattern.</a>

</p></aside>

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

The first line tells `make` that `submit` is a phony target. The second line
means that the command is complete once we've built all of its prerequisites,
which would just be `submit.tar.gz` here. That means that in order to `make
submit`, `make` just needs to ensure `submit.tar.gz` is up-to-date.

<aside class="aside-info"><p>

If you don't mark your target as phony, <code>make</code> will start behaving
very strangely if there actually is a file called <code>submit</code> in the
directory. It may refuse to build at all or build unnecessarily every time, and
you may not notice until you've already wasted a submit or two.

</p></aside>

# Syncing with CAEN

The `make sync` command will also be a phony target, since we don't actually
want to create a file called `sync`.

At this point, you should consider whether or not there are any dependencies for
this command. Intuitively, yes, there are dependencies --- whatever source files
you have. However, the `sync` command doesn't actually produce any files, and
since `make` checks the modified time of the build result and compares the
modified time of any prerequisites, it doesn't have any way to know whether a
`sync` actually needs to be done.

  [ssh-aliases]: {{ site.baseurl }}/dealing-with-caen

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
