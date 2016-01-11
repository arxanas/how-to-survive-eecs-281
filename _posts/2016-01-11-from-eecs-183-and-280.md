---
layout: post
title: What EECS 183 and 280 didn't mention
subtitle: Common issues we see in incoming students.
category: coding
permalink: /from-eecs-183-and-280/
---

There's a set of common coding and testing mistakes that incoming students make.
You can save yourself a lot of headache by reading about them now, rather than
being confused later.

* toc
{:toc}

## Coding

### Exiting the program

How do you exit the program? The first idea that may come to mind is to call
`exit(0)` (or `exit(1)`, if appropriate).

If you call `exit`, destructors will not be run. This means that you may not
free memory in those destructors, and the autograder may detect a memory leak.
(For example, if you have a `vector` and call `exit`, the `vector` will not
delete its underlying array.)

You should structure your program in such a way that you can `return 0` from
`main` instead, which will allow destructors to run.

### Iterators and auto

We encourage the use of C++14 in this class. One feature of C++14 is `auto`,
which lets you omit types in many cases. (This feature is available since
C++11). In particular, avoid typing out long container iterator declarations:

{% highlight cpp %}
std::vector<int> myvec = {1, 2, 3};

// Don't do this!
for (std::vector<int>::iterator it = myvec.begin(); it != myvec.end(); ++it) {
    // ...
}
{% endhighlight %}

Explicitly typing out these declarations is tedious, difficult to refactor, and
inevitably causes at least one student to have confusing compiler errors
relating to modifying a member `vector` inside a `const` member function.

Instead, write this:

{% highlight cpp %}
std::vector<int> myvec = {1, 2, 3};

for (auto it = myvec.begin(); it != myvec.end(); ++it) {
    // ...
}
{% endhighlight %}

This is shorter, won't break your code when you change the type of `myvec`, and
will automatically handle `const` issues. See also [range-based for
loops](#range-based-for-loops) for an even *better* way of doing it.

<aside class="aside-info"><p>

<code>auto</code> only works if you're doing a declaration and an assignment in
the same line, since then the compiler can figure out the type of your variable.

</p><p>

If you're just trying to declare a variable with an automatically inferred type,
and you're not assigning it, use <code>decltype</code> instead.

</p></aside>

### Range-based for loops

As of C++11, you can use "range-based for loop" syntax to iterate through a
container:

{% highlight cpp %}
std::vector<int> myvec = {1, 2, 3};

for (auto num : myvec) {
    // ...
}
{% endhighlight %}

This automatically does the hard work of dereferencing iterators for you. Notice
that `num` is an `int`, not an iterator. When possible, use this syntax as it is
the shortest and easiest to read.

Make sure to pass your for-loop variable by reference or const reference if
applicable:

{% highlight cpp %}
std::vector<LargeStruct> myvec = makeVec();

for (const auto& largeStruct : myvec) {
    // ...
}
{% endhighlight %}

### Using <code>break</code>

The EECS 183 style guide forbids using `break` to terminate loops. There's
evidence to suggest that this doesn't actually help code clarity: see Code
Complete 2, Chapter 16: Controlling Loops, or the referenced study by Soloway,
Bonar, and Ehrlich (1983), which both outline how using `break` can enhance the
readability of your code.

<aside class="aside-info"><p>

Is that paper by our very own Professor Soloway? Yes it is. Go read it.

</p></aside>

If you have examined both arguments and still opt not to use `break`, which is a
fine viewpoint to hold, you absolutely must not use hacks like this to terminate
your loop early:

{% highlight cpp %}
for (int i = 0; i < myvec.size(); i++) {
    if (condition()) {
        // Break out, but don't use the `break` keyword.
        i = size;
    } else {
        // Do work...
    }
}
{% endhighlight %}

This is only ever worse than `break`, since it's fragile (changing the loop
condition can cause your code to, ehm, break) and its significance can be
unclear. At this point, you should just use `break`.

### Reading input

The C++ input routines may not be the most intuitive at times. Unfortunately,
it's easy to accidentally produce something that works on your machine but then
fails on the autograder.

#### The wrong way to read input

This code is buggy. Can you see why?

{% highlight cpp %}

while (std::cin.good()) {
    int foo = 0;
    std::cin >> foo;
    cout << "Got foo: " << foo << endl;
}

{% endhighlight %}

The problem is that `cin.good()` doesn't return `false` until an operation has
failed. That means for the last iteration, it will try to read a value into
`foo` and fail, without you realizing it! Running with input like `1 2 3` may
cause output like this:

{% highlight text %}
Got foo: 1
Got foo: 2
Got foo: 3
Got foo: 0
{% endhighlight %}

An extra entry has appeared! In practice, your program may do unusual things
like duplicate the last entry or just crash. (`valgrind` didn't even detect this
when I tested this program.) You will likely fail most test cases on the
autograder if you've done this.

#### The right way to read input

Instead, combine the loop condition and the input reading operation:

{% highlight cpp %}
int foo;
int bar;
int baz;
while (std::cin >> foo >> bar >> baz) {
    // Do something, but only if we read in all of our variables.
}
{% endhighlight %}

This causes the body of the loop to execute only if we successfully read in all
of our desired variables.

If for some reason the above approach isn't appropriate for your code, you can
fall back on checking the status of your input stream *after* trying to read
from it.

{% highlight cpp %}
while (true) {
    int foo;
    int bar;
    int baz;
    std::cin >> foo >> bar >> baz;
    if (!std::cin) {
        // Finished reading input file.
        break;
    }
    // Do something.
}
{% endhighlight %}
  

## Testing

### Copying from the spec

You must not copy strings directly from the PDF. These often contain invisible
characters, which your program will choke on. Instead, type strings into your
editor manually. (Or, if the test file is available on Ctools, use that.)

### Using Windows to edit files

Windows and Unix systems use different linebreaks. Windows uses a sequence of
two characters (carriage return followed by line feed, or CRLF), while Unix uses
just one (line feed, or LF).

If you are creating test files on Windows, you may accidentally create a file
that uses Windows linebreaks, which your program may not be equipped to deal
with. If you try to submit it to the autograder as a test case, the autograder
may reject it for being invalid.

#### Checking for Windows linebreaks

To see if your test file has Windows linebreaks, you can run this command:

{% highlight sh %}
$ grep -c '\r' my-test-file.txt
{% endhighlight %}

This counts the number of Windows linebreaks. If it produces a number greater
than zero, then you'll need to remove linebreaks.

#### Removing Windows linebreaks

The simplest way is to run `dos2unix` on your test file:

{% highlight sh %}
$ dos2unix my-test-file.txt
dos2unix: converting file foo to Unix format...
{% endhighlight %}

If you don't have `dos2unix` installed, you can do something like this:

{% highlight sh %}
$ tr -d '\r' <my-test-file.txt >my-test-file.txt.new
$ mv my-test-file.txt.new my-test-file.txt
{% endhighlight %}

<aside class="aside-warning"><p>

You must <em>not</em> do <code>tr -d '\r' &lt;my-test-file.txt
&gt;my-test-file.txt</code>, as this will delete the contents of your file.

</p></aside>
