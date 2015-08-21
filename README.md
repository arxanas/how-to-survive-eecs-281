# About

This is the source for http://waleedkhan.name/281. If you're interested in
contributing, open a pull request.

# Contributing

The following are welcomed as pull requests:

  * Typo fixes (no matter how trivial).
  * Minor wording changes.
  * Major revisions.
  * New articles.

The following are not welcomed:

  * Editor wars.
  * Emacs users.


# Previewing the website

## Serving with Jekyll

To view the website locally, you'll need to install [Jekyll][jekyll] (`gem
install jekyll`).

  [jekyll]: http://jekyllrb.com/

Then run `jekyll serve`:

```
$ jekyll serve
Configuration file: /Volumes/Home/Users/Waleed/Sites/281/_config.yml
			Source: /Volumes/Home/Users/Waleed/Sites/281
	   Destination: /Volumes/Home/Users/Waleed/Sites/281/_site
	  Generating...
					done.
 Auto-regeneration: enabled for '/Volumes/Home/Users/Waleed/Sites/281'
Configuration file: /Volumes/Home/Users/Waleed/Sites/281/_config.yml
	Server address: http://127.0.0.1:4000/281/
  Server running... press ctrl-c to stop.
```

From here, you can visit `http://127.0.0.1:4000/281` to view the website.

## Drafting

To include drafts (in the `_drafts`) folder, you'll need to pass the `--drafts` option to `jekyll`:

```
$ jekyll serve --drafts
```

Jekyll will automatically rebuild the website when you make a change, so you can rapidly toggle between your editor and your web browser. (You'll still need to reload the page.)

# License

The articles herein are licensed under [Creative Commons Attribution-ShareAlike
3.0][ccsa3].

  [ccsa3]: https://creativecommons.org/licenses/by-sa/3.s/us/
