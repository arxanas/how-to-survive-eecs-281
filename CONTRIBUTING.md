# Style guide

## Header levels

Start at header level 2 for headers. (Header level 1 is for the large title at
the top of the page.) Your first header should use two `#`s:

```
## My top-level header
### My sub-header
Content.

## My next top-level header
```

## Header casing

For header titles, capitalize the first word, but not the remainder. For
example:

```
## This is a header title
```

## Table of contents

Include a table of contents in articles, unless they're particularly short. You
can generate one by putting this snippet at the place where you want the table
of contents to be generated.

```
* toc
{:toc}
```

The table of contents does not get its own header: that would cause the table of
contents to be listed in the table of contents, and it's a bit jarring anyways.

Typically, any introductory paragraphs should go before the table of contents,
like Wikipedia.

## Asides

Use asides to demarcate different types of content.

To create an aside, you'll have to drop into HTML mode. This means that the
various Markdown formatting facilities won't work, so you'll have to write them
out by hand.

```
Some text

<aside class="aside-info"><p>

Here's a helpful tip, with an <code>inline code snippet</code>, some
<em>italics</em>, and so on.

</p></aside>
```

For information that's tangentially useful, but won't directly help the reader,
use an aside with the `aside-info` class. The reader should be able to gather a
working understanding of the subject without reading it.

For emphasis on points that should be heeded by the reader, use the
`aside-warning` class. This stands out and makes it less likely that the reader
will skim over an important caveat. It can be used simply to emphasize a point
which would otherwise appear in the main text.

For especially dire issues ("your code may be deleted if you don't
do it exactly like this..."), use `aside-critical`.

For remarks on improving efficiency, but the lack of which wouldn't cause the
reader to be unable to utilize the provided information, use `aside-tip`.  If
the tip is subjective, it may be provided here with appropriate disclaiming
language ("one way you can do this is to...", or "my preference is to...").
