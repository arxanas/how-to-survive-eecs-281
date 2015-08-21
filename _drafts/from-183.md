---
layout: post
title: What they didn't teach you in 183 and 280
subtitle: Common issues we see in incoming students.
permalink: /from-183-and-280/
---


# Coding

## Reading input

The C++ input routines may not be the most intuitive at times. Unfortunately,
it's easy to accidentally produce something that works on your machine but then
fails on the autograder.

Can you see the bug in this code?

{% highlight cpp %}

while (cin.good()) {
    int foo;
    cin >> foo;
    cout << "Got foo: " << foo << endl;
}

{% endhighlight %}

The problem is that `cin.good()` returns

# Testing
