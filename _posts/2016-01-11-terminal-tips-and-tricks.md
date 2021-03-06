---
layout: post
title: Terminal Tips and Tricks
subtitle: Stop pressing <kbd>up</kbd> a million times to
  find that <code>g++</code> command!
category: workflow
permalink: /terminal-tips-and-tricks/
---
You probably spend a lot of time on CAEN, or SSHed into CAEN, or working on a
terminal on your local machine. It's probably worth learning a few keyboard
shortcuts so that you can spend less time fiddling with your terminal and more
time programming.

Some terminology: the *shell* is the program that you use to interact with
programs on CAEN and the files in your home directory. It's often used
interchangeably with terms like *terminal*, *command line*, and *command
prompt*.

<aside class="aside-info">

<p>Strictly speaking, <em>terminal</em> isn't synonymous with <em>shell</em>.
"Terminal" is actually short for "terminal emulator", a piece of software which
draws all of the characters on your screen, handles escape sequences, and so on.
It's an emulator because it mimics the old machines which used to do all this,
such as the VT100. So you use a terminal emulator to interact with your
shell.</p>

</aside>

The default shell on CAEN is `bash`. In fact, it's the default shell on many
systems, such as OS X and many breeds of Linux. There are other shells; many
people swear by `zsh`, so feel free to try another one out. The tips listed here
are compatible with both `bash` and `zsh`, and probably other shells as well.

You don't need to read this document from beginning to end. Scan through the
headings and look at any appealing sections. If you had to read only one thing,
it should be [tab-completion](#tab-completion).

* toc
{:toc}

## Keyboard shortcuts

`bash` uses Emacs keybindings by default, so if you happen to use Emacs then you
probably already know what to do.

### Tab-completion

You can tab-complete file and directory names in `bash`. For example:

    $ cd e<tab>
    $ ./p<tab> < te<tab>-1<tab>

might be equivalent to

    $ cd eecs281
    $ ./program < test-1.txt

Tab-completion saves time and helps you to avoid spelling mistakes.

If a filename is ambiguous, you may see a listing of filenames, like this:

    $ cd f<tab>
    foo1/  foo2/

You can continue typing the filename and then press tab again to fully complete
the filename.

### Searching through history

Everyone who's used a shell has at some point in their life spammed the
<kbd>up</kbd>-key to find their last `g++` command, or last program invocation,
or whatever else kids do nowadays on their terminals. Fortunately, `bash` has a
command for exactly this. At your terminal prompt, type <kbd>Ctrl-R</kbd>. It
should look like this:

{% highlight sh %}
(reverse-i-search)`':
{% endhighlight %}

Then start typing. For example, if I type `g++` it might look like this:

{% highlight sh %}
(reverse-i-search)`g++': g++ main.cpp
{% endhighlight %}

The thing after the colon is the first match. Tap <kbd>Ctrl-R</kbd> again to see
the match before that, and so on.

When you find the command you want, press <kbd>Enter</kbd> to run it. You can
also edit the command before running it by pressing an arrow key or text
manipulation key (see the next section).

### Text manipulation

Type <kbd>Ctrl-W</kbd> to delete the word before the cursor. Type
<kbd>Ctrl-A</kbd> to go to the beginning of the line (handy if you forgot a
`sudo` or a `./`), and <kbd>Ctrl-E</kbd> to go to the end of a line.

<aside class="aside-tip"><p>

Again, these are just Emacs keybindings. If you learn any more, you can probably
apply them to <code>bash</code>.

</p></aside>

### Screen manipulation

To exit your terminal, you can type <kbd>Ctrl-D</kbd> to send `EOF`
(end-of-file). You can also do this anywhere else you want to signify the end of
a file. One useful place is when you're done typing things into `stdin`.

Instead of pressing <kbd>Enter</kbd> many times or running the `clear` command,
you can just type <kbd>Ctrl-L</kbd> to clear the screen. (I personally remember
it because <kbd>Ctrl-C</kbd> for "clear" is taken, so we use the next letter in
the alphabet.) If you do this, you might remark that it's hard to scroll up to
the beginning of your compiler output --- see the following section on pagers
for dealing with that.

## Scrolling through program output

Sometimes, commands produce a lot of output, and it's a pain to scroll through
it all. We can use a program called a *pager* to peruse it at our leisure. One
ubiquitous pager is `less`.

### Viewing files

To view the output of a file with `less`, invoke `less` with the filename:

{% highlight sh %}
$ less my-file.txt
{% endhighlight %}

You'll get output like this. The colon at the bottom is for `less`'s status
line.

    You probably spend a lot of time on CAEN, or SSHed into CAEN, or working on a
    terminal on your local machine. It's probably worth learning a few keyboard
    shortcuts so that you can spend less time fiddling with your terminal and more
    time programming.
    
    First, some terminology: the *shell* is the program that you use to interact
    with programs on CAEN and the files in your home directory. It's often used
    interchangeably with terms like *terminal*, *command line*, and *command
    prompt*.
    
    <aside class="aside-info">
    :

**Scrolling**: Use <kbd>up</kbd> and <kbd>down</kbd>. To scroll a page at a
time, use <kbd>PgUp</kbd> and <kbd>PgDn</kbd>. You can also use Vim keybindings:
I often use <kbd>Ctrl-U</kbd> and <kbd>Ctrl-D</kbd> to go up and down
pages.

**Quitting**: Type <kbd>q</kbd>.

**Searching**: Type <kbd>/</kbd> and then your search string to search forward.
Use <kbd>?</kbd> to search backward instead. (Notice that <kbd>?</kbd> is just
<kbd>Shift-/</kbd>.)

**Jump to top/bottom**: Type <kbd>G</kbd> to go to the bottom of the file, and
<kbd>g</kbd> to go to the top. (These are similar to Vim keybindings. If you
forget which is which, try both: one is bound to perform the desired action.)

### Viewing command output

If you want to view the output from your program, or the output from your
compiler, you can pipe directly into less, instead of saving the output to a
file and then reading it:

{% highlight sh %}
$ ./my-program | less
{% endhighlight %}

This only forwards `stdout` to `less`. If you want to forward `stderr` as well,
you can use the `|&` operator.

{% highlight sh %}
$ g++ main.cpp |& less
{% endhighlight %}

<aside class="aside-tip"><p>

Compiler errors are produced on stderr, so you'll almost always want to use
<code>|&</code>.

</p></aside>

Now you can use all the `less` commands from the previous section to scroll and
search through your output.

<aside class="aside-warning"><p>

The <code>|&</code> operator is a <code>bash</code>-ism. It may not work in all
shells.

</p></aside>

## Showing file differences

If you want to run tests and show differences automatically, take a look at
[Painless Automated Testing]({{ site.baseurl }}{% post_url 2014-12-21-painless-automated-testing %}).

The `diff` command takes two files and tells you how they're different. For
example:

{% highlight sh %}
$ diff file-1 file-2
3c3
< Different line 1
---
> Different line 2
{% endhighlight %}

If there's a lot of changes, you might want to pass the output from `diff` into
`less`, as specified above.

Better still, you can use the `vimdiff` command for a convenient, colorized
side-by-side diff:

{% highlight sh %}
$ vimdiff file-1 file-2
{% endhighlight %}

You can use all of the `less` keybindings you learned above, except that to
quit, you need to type `:qall`. You can also use any other Vim keybindings you
know, since this is actually Vim.

{% image vimdiff.png "Highlighting differences in vim." %}

## Multiple terminals at once

Many people are okay with having multiple terminal windows open, so this section
won't be useful to them. But if you hate having to SSH into CAEN for every new
terminal window you open, or you just want to look cool, you can use a *terminal
multiplexer*. A terminal multiplexer will let you have multiple sessions at
once. CAEN has `screen` and `tmux` installed; we'll talk about `tmux` since it's
mostly better.

### Using windows

Launch `tmux` in your terminal on CAEN. You should get a new, blank screen,
except with a status line at the bottom. (It'll say something like `0:bash`.)

{% image tmux-new-screen.png "A new tmux session." %}

Run a simple command, like `echo hi`, and see that it works the same as your
regular terminal.

**Getting help**: Run <kbd>Ctrl-b ?</kbd> (which means <kbd>Ctrl-b</kbd>, then
lift up your fingers, then <kbd>?</kbd>) to get a list of current keybindings.
Press <kbd>q</kbd> to exit that screen.

**Creating windows**: Use <kbd>Ctrl-b c</kbd>. (Make sure to stop pressing
<kbd>Ctrl</kbd> before pressing <kbd>c</kbd>.) This creates a new, empty
terminal window, which you can run different commands in. You can see all the
open windows in the statusline at the bottom.

{% image tmux-new-window.png "Two tmux windows are open at once." %}

**Switching windows**: Use <kbd>Ctrl-b n</kbd> and <kbd>Ctrl-b p</kbd> (for
*next* and *previous*). You can jump directly to a window with <kbd>Ctrl-b</kbd>
followed by the index of the window (for example, <kbd>Ctrl-b 0</kbd> to jump to
the window labelled 0).

<aside class="aside-tip"><p>

Window numbering is zero-indexed, which is "intuitive", but it also means that
you have to reach all the way over to the zero key to select the first window.
You can set the <code>base-index</code> option to <code>1</code> <a
href="#binding-keys">in your <code>.tmux.conf</code> file</a> to make life a bit
easier on your fingers.

</p></aside>

**Destroying windows**: If you want to close a window, just exit the shell. You
can do this with the `exit` command, or you can type <kbd>Ctrl-d</kbd> at an
empty prompt. When all windows are closed, `tmux` will exit.

**Examining output**: If you want to scroll up and see old output, you can type
<kbd>Ctrl-b PgUp</kbd> and <kbd>Ctrl-b PgDn</kbd>. You can search forward
through old output with <kbd>Ctrl-b /</kbd> and backwards with <kbd>Ctrl-b
?</kbd>. This can be convenient if you forgot to [pipe your output into a pager
or a file](#viewing-files).

{% image tmux-scroll-up.png "Scroll through old output." %}

### Using panes

You can also show more than one shell on the screen at once, by using "panes".
Type <kbd>Ctrl-b "</kbd> to split the current window into an upper and lower
pane. Type <kbd>Ctrl-b %</kbd> to split the current window into a left and right
pane.

{% image tmux-multiple-panes.png "Multiple tmux panes open at once." %}

To switch between panes, use <kbd>Ctrl-b</kbd> followed by an arrow key.

Panes will be destroyed when the shell exits, just the same as windows.

### Binding keys

To see all of the active keyboard bindings available for `tmux`, run <kbd>Ctrl-b
?</kbd>.

You can rebind all of these actions, which is fortunate since <kbd>Ctrl-b</kbd>
is not very ergonomic. Create the file `~/.tmux.conf` if it doesn't already
exist, and add line `set-option -g prefix C-a`. This sets your "prefix" key,
which is <kbd>Ctrl-b</kbd> by default, to be <kbd>Ctrl-a</kbd>. You can set it
to whatever you want, of course.

`tmux` is quite customizable. Take a look at the internet, the `man`-pages, or
some example `.tmux.conf` files if you want more inspiration. Here's mine,
although I wouldn't recommend that you copy it verbatim:
[https://github.com/arxanas/dotfiles/blob/master/.tmux.conf](https://github.com/arxanas/dotfiles/blob/master/.tmux.conf).
