---
layout: post
title: Painless Automated Testing
subtitle: Running a test suite automatically in ten lines of code.
category: coding
permalink: /painless-automated-testing/
---

I'm guessing that you don't like testing. Fortunately, we can make testing a lot
easier to do by writing a script to do it for us. In this post, you'll learn how
to write a simple shell script which will run your program with input and
compare it against the expected output.

This post looks long, but it's mostly sections with one paragraph each. Just
follow the instructions step-by-step and you'll be set.

<aside class="aside-warning"><p>

In the interest of brevity, this document doesn't touch upon best practices for
shell scripting. Everything described here works just fine, but there are a lot
of hidden pitfalls when it comes to shell scripting. Consult a style guide
before trying to write your next operating system in <code>bash</code>

</p></aside>

## What's a shell script?

When you log into CAEN over SSH, you're presented with a prompt where you can
type things like `cd`, `cp`, `mv`, and so on. The program that does this for you
is called a *shell*. Instead of typing in commands by hand, we can put them in a
file to be executed automatically, called a *shell script*.

<aside class="aside-info"><p>

The shell we use on CAEN is called <code>bash</code>, but it's not the only shell out there. There are many others, like <code>zsh</code>, <code>csh</code>, <code>ksh</code>... Feel free to try another one — a lot of people recommend <code>zsh</code>.

</p></aside>

## Writing our first shell script

Create a file called `helloworld.sh` and open it up in your editor. The `.sh` extension is the conventional extension for a shell script. Type this out in your file:

{% highlight sh %}
echo "Hello, world!"
{% endhighlight %}

Then go to your terminal and run the script using `bash`:

{% highlight sh %}
$ bash helloworld.sh
Hello, world!
{% endhighlight %}

That wasn't too hard!

<aside class="aside-warning"><p>

Make sure <em>not</em> to type the <code>$</code> at the beginning of each line.
We use lines beginning with <code>$</code> to denote commands that you type in,
and lines not beginning with <code>$</code> to denote their output. You only
have to type in commands on lines beginning with <code>$</code>.

</p></aside>

## Example test files

For the sake of example, let's say we have a program `adder` which adds up all
the numbers given to it on standard input and prints the result to standard
output. (This means it reads from `cin` and writes to `cout`.)

Let's write the first test. Create `test-1.input` with the following contents:

```txt
2 3 4
```


And `test-1.output`:

```txt
9
```

## Writing the script

Now onto writing the test runner. Create `run_tests.sh`:

{% highlight sh %}
for test in ./test-*.input; do
    # Compare program output with expected output...
done
{% endhighlight %}

As you can see, we have a `for`-loop here. But what's this `./test-*.input`?
This is a type of pattern-matching statement called a *glob*. It matches all of
the files in the current directory which start with `test-` and end with
`.input`. For each such file, it puts the file name in the `$test` variable and
runs the `for`-loop body. Basically, we're iterating over a list of file names
matching the glob pattern.

<aside class="aside-warning"><p>

If you're familiar with regular expressions, you may recognize the
<code>*</code> character. However, <code>*</code> does a different thing when
globbing: it's basically equivalent to the regex <code>.*</code>.

</p></aside>

<aside class="aside-warning"><p>

<code>bash</code> is silly: if there aren't actually any files matching the
pattern, instead of not running your loop at all, it will run it with the
literal string <code>./test-*.input</code>. Since you probably don't have any
files like that in your current directory, this will be an error.

Either make sure to have the files in place, or add the line <code>shopt -s
nullglob</code> to the beginning of your script.

</p></aside>

## A brief note on bash syntax

Some notes before we continue: in `bash`, whenever we want to read the value of
a variable, we have to prefix it with `$`. (In the `for`-loop condition, we were
*writing* to the variable, so we didn't need a `$`.)

Additionally, `bash` will automatically *interpolate* string variables. If we
say this:

{% highlight sh %}
echo "Test name: $test"
{% endhighlight %}

then `bash` will automatically replace `$test` with the actual contents of the
`test` variable, so we'll get something like `Test name: test-1.input`.

## Getting the output file name

Now that we have the input file name, we need to get the output file name. In
short, we need to remove the `.input` extension and replace it with the
`.output` extension.

We can use some convenient `bash` string manipulation facilities to do this.
Let's declare a new variable inside the `for`-loop:

{% highlight sh %}
for test in ./test-*.input; do
    # Right now, this just copies the contents of 'test' into the variable
    # called 'test_output'.
    test_output="$test"

    # Do other things...
done
{% endhighlight %}

If we want to remove a substring from the end of a string in bash, we can use
the `%` operator:

{% highlight sh %}
for test in ./test-*.input; do
    # So the contents of test_output would now be "test-1" instead of
    # "test-1.input".
    test_output="${test%.input}"

    # Do other things...
done
{% endhighlight %}

<aside class="aside-info"><p>

I admit, I just looked up how to remove the end of a string in
<code>bash</code>. <a
href="http://tldp.org/LDP/abs/html/string-manipulation.html">Here's the
documentation I looked at</a>; the examples are pretty good if you want to
experiment on your own.

</p></aside>

Now we just need to tack on the `.output` extension:

{% highlight sh %}
for test in ./test-*.input; do
    # Now 'test_output' contains "test-1.output".
    test_output="${test%.input}.output"

    # Do other things...
done
{% endhighlight %}

## Actually doing the comparison

First, we want to run our program and see its output:

{% highlight sh %}
for test in ./test-*.input; do
    test_output="${test%.input}.output"

    ./adder <"$test"
done
{% endhighlight %}

<aside class="aside-info"><p>

You may notice that we've put <code>$test</code> into quotes. If
<code>$test</code>, for example, contained spaces, <code>bash</code> might think
that they're additional command line parameters or something else silly. For
robustness and security, you should always quote variables when using them in
<code>bash</code>.

</p></aside>

We're using the input redirection operator `<` here to feed the contents of the
input test file to our `adder` program. But as it is, this just prints the
result to the screen. We want to feed it to the `diff` program, along with the
correct output, to tell us if the files were identical.

To hook together our program and `diff`, we can use a *pipeline*. This will
redirect the standard output of `adder` to the standard input of `diff`. To use
a pipeline for `cmd1` and `cmd2`, we join the two with the `|` operator to get
`cmd1 | cmd2`:

{% highlight sh %}
for test in ./test-*.input; do
    test_output="${test%.input}.output"

    # 'adder' will feed its output directly into 'diff'.
    ./adder <"$test" | diff - "$test_output"
done
{% endhighlight %}

You'll notice that we have the file `-` as one of the parameters to diff. This
is special code meaning "use standard input for this file". The other file is
the correct output file.

## Checking to see if the test passed

Finally, we just need to check the return value of `diff` to see if the files
were identical. We can use <code>bash</code>'s `if`-statement to determine if a
command succeeded or not. If the command has an exit code of zero, the `if`
statement considers it a success and goes into the `if`-branch; otherwise, it
goes into the `else`-branch (if there is one).

<aside class="aside-info"><p>

You'll notice that this is the opposite of what we usually expect from boolean
logic. Normally, a value of zero means <code>false</code>, but here zero means
success.

Why use zero for success and non-zero for failure? It's more convenient for us
scripters. There's usually only one way a program can successfully run, but many
ways it can fail. If we want to know why exactly a program failed, we can just
check the exit code.

</p></aside>

We'll just move the command into the condition of an `if` statement:

{% highlight sh %}
for test in ./test-*.input; do
    test_output="${test%.input}.output"

    if ./adder <"$test" | diff - "$test_output"; then
        echo "Test $test passed!"
    else
        echo "Test $test failed..."
        exit 1
    fi
done
{% endhighlight %}

That's it! We have our automated test runner in ten lines of code. If we run
`bash run_tests.sh` now, it will automatically run all of the tests in the
current directory. If any of them fail, then the test runner will `exit 1`.

## Adding automatic test-running to our Makefile

Now that we've written our test runner, we can do a few nifty things with it.
First off, let's make it so that if we run `make test`, our tests will be run.
Add these lines to your `Makefile`:

{% highlight make %}
test: all
	bash run_tests.sh
{% endhighlight %}

<aside class="aside-warning"><p>

Remember that in a `Makefile`, you must use tabs for indentation. Otherwise
`make` will fail and give you a cryptic error.

</p></aside>

Now if we run `make test`, we'll either get output like this:

{% highlight sh %}
$ make test
bash run_tests.sh
Test ./test-1.input passed!
{% endhighlight %}

Or, if we're unlucky, this:

{% highlight sh %}
$ make test
bash run_tests.sh
1c1
< 9
---
> 10
Test ./test-1.input failed...
make: *** [test] Error 1
{% endhighlight %}

## Preventing submission if our tests failed

Since we've added the `test` target to our `Makefile`, we can also make it so
that `make` will refuse to make `submit.tar.gz` if your tests failed to pass.
(This can save you quite a few submits down the road if you're lazy and don't
want to test every single thing by hand.) Just modify the `submit` target from
this:

{% highlight make %}
submit: submit.tar.gz
{% endhighlight %}

to this:

{% highlight make %}
submit: test submit.tar.gz
{% endhighlight %}

Now if you try to run `make submit` and your tests fail, `make` will refuse to
build your submission file and let you know.

## If you get stuck...

Shell scripting can have some really hard-to-diagnose errors, especially if
you're not experienced in it. If you get stuck, make a new post on Piazza, or
just email me!

If you're writing a significantly-sized shell script and are having trouble with
it, consider enabling the so-called <a
href="http://redsymbol.net/articles/unofficial-bash-strict-mode/">bash strict
mode</a>. This might cause your error to trigger earlier so you can figure out
what went wrong.
