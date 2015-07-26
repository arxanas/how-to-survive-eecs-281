---
layout: post
title: Terminal Tips and Tricks
subtitle: Stop pressing <kbd>up</kbd> a million times to
  find that <code>g++</code> command!
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

<p>Strictly speaking, <i>terminal</i> isn't synonymous with <i>shell</i>.
"Terminal" is actually short for "terminal emulator", a piece of software which
draws all of the characters on your screen, handles escape sequences, and so on.
It's an emulator because it mimics the old machines which used to do all this,
such as the VT100. So you use a terminal emulator to interact with your
shell.</p>

<p>In practice, nobody cares.</p>

</aside>

The default shell on CAEN is `bash`. In fact, it's the default shell on many
systems, such as OS X and many breeds of Linux. There are other shells; many
people swear by `zsh`, so feel free to try another one out. The tips listed here
are compatible with `zsh` and probably other shells as well.

You don't need to read this document from beginning to end. I'd recommend you
scan through the headings and just look at any of the sections which seem
appealing.

## Keyboard Shortcuts

`bash` uses Emacs keybindings by default, so if you happen to use Emacs then you
probably already know what to do.

### Searching through history

Everyone who's used a shell has at some point in their life spammed the
<kbd>up</kbd>-key to find their last `g++` command, or last program invocation,
or whatever else kids do nowadays on their terminals. Fortunately, `bash` has
<kbd>Ctrl-R</kbd> for exactly this. At your terminal prompt, type
<kbd>Ctrl-R</kbd>. It should look like this:

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
manipulation key.

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
<kbd>gg</kbd> to go to the top. (Why these keys? They're also Vim keybindings.
If you forget, try both; one is bound to do what you want it to do.)

### Viewing command output

If you want to view the output from your program, or the output from your
compiler, you can pipe directly into less, instead of saving the output to a
file and then reading it:

{% highlight sh %}
$ ./my-program | less
{% endhighlight %}

This only forwards `stdout` to `less`. If you want to forward `stderr` as well,
you can use the `|&` operator. You probably want to do this whenever you compile
something:

{% highlight sh %}
$ g++ main.cpp |& less
{% endhighlight %}

Now you can use all the `less` commands from the previous section to scroll and
search through your output.

<aside class="aside-warning"><p>

The <code>|&</code> operator is a <code>bash</code>-ism. It may not work in all
shells.

</p></aside>

## Showing file differences

TODO: Include link to /painless-automated-testing/. Make it not-hardcoded,
ideally. Is there a url-for-permalink function?

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

TODO: Show picture.

## Multiple terminals at once

Most people are okay with having multiple terminal windows open, so this section
won't be useful to them. But if you hate having to SSH into CAEN for every new
terminal window you open, or you just want to look cool, you can use a *terminal
multiplexer*. A terminal multiplexer will let you have multiple sessions at
once. CAEN has `screen` and `tmux` installed; we'll talk about `tmux` since it's
mostly better.

### Using windows

Launch `tmux` in your terminal. You should get a new, blank screen, except with
a status line at the bottom. (It'll say something like `0:bash`.)

Run a simple command, like `echo hi`, and see that it works the same as your
regular terminal.

Type <kbd>Ctrl-b c</kbd> (which means <kbd>Ctrl-b</kbd>, then lift up your
fingers, then <kbd>c</kbd>). This creates a new, empty terminal window. To
switch between your terminal windows, use <kbd>Ctrl-b n</kbd> and <kbd>Ctrl-b
p</kbd> (for next and previous).

If you want to close a window, just exit the shell. You can do this with the
`exit` command, or you can use <kbd>Ctrl-d</kbd> at an empty prompt. When all
windows are closed, `tmux` will exit.

### Using panes

You can also show more than one shell on the screen at once, by using "panes".
Type <kbd>Ctrl-b "</kbd> to split the current window into an upper and lower
pane. Type <kbd>Ctrl-b %</kbd> to split the current window into a left and right
pane.

To switch between panes, use <kbd>Ctrl-b</kbd> followed by an arrow key.

Panes will be destroyed when the shell exits, just the same as windows.

TODO: Show picture.

### Binding keys

To see all of the active keyboard bindings available for `tmux`, run <kbd>Ctrl-b
?</kbd>.

You can rebind all of these actions, which is fortunate since <kbd>Ctrl-b</kbd>
is not very ergonomic. Create the file `~/.tmux.conf` if it doesn't already
exist, and add line `set-option -g prefix C-a`. This sets your "prefix" key,
which is <kbd>Ctrl-b</kbd> by default, to be <kbd>Ctrl-a</kbd>. You can set it
to whatever you want, of course.

`tmux` is quite customizable. Take a look at the internet, the `man`-pages, or
some example `.tmux.conf` files if you want more inspiration. (Here's mine:
https://github.com/arxanas/dotfiles TODO: Put a full link to the actual
`.tmux.conf` file.)
