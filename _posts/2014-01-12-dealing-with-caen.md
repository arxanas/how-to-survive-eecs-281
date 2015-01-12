---
layout: post
title: Dealing with CAEN
subtitle: Connecting to and uploading/downloading from CAEN efficiently.
permalink: /dealing-with-caen/
---
This is a handful of tips for managing files on CAEN effectively using command
line tools. Alternatives include [MFile][mfile], using an SFTP
client, or using an SFTP plugin for your editor.

  [mfile]: http://mfile.umich.edu

If you're using Sublime Text, many students use an SFTP plugin to automatically
upload files to CAEN. However, I don't have any experience with it and thus
cannot offer any configuration advice.

At the end of this article, there's a guide to mounting a directory on CAEN as
if it were on your local computer, but it only works in OS X and Linux. You may
prefer to use this to avoid having to manually keep things in sync.

# Stop typing `login.engin.umich.edu` using by SSH aliases

You probably don't like typing the verbose `ssh you@login.engin.umich.edu` all
the time. Fortunately, `ssh` has a built-in method for setting up *aliases* for
hosts. Edit the file `~/.ssh/config` and add these lines (changing `you` to
your uniqname):

    Host caen
      HostName login.engin.umich.edu
      User you

This sets up a new alias, so now you can type `ssh caen` instead to log into
CAEN.

# Uploading files to CAEN

You can use the `scp` command (secure copy) to copy files to and from CAEN.
`scp`'s syntax is the same as `cp`'s, except that either the source or
destination should be on a remote host.

<aside class="aside-warning"><p>

You'll want to use <code>scp</code> by running it on your local machine
(probably the computer you're viewing this on right now). <code>scp</code> will
let you both upload and download files, but both will be done from your local
machine.

</p></aside>

For example, to copy `my-file.cpp` to the `project-1` directory CAEN, you could
do this:

{% highlight sh %}
$ scp my-file.cpp you@login.engin.umich.edu:project-1
{% endhighlight %}

Of course, you don't want to type out the whole `you@login.engin.umich.edu` bit
every time, so we can use the SSH alias you just set up:

{% highlight sh %}
$ scp my-file.cpp caen:project-1
{% endhighlight %}

<aside class="aside-tip"><p>

The path specified after <code>:</code> is relative to your home directory. If
you wanted to copy a file to your home directory, you would just write <code>scp
my-file.cpp caen:</code>, with a colon and nothing after it.

</p></aside>

If you want to copy a whole directory, then you need to pass the `-r`
(recursive) flag, just like with `cp`. To copy `my-directory` into your
`project-1` directory:

{% highlight sh %}
$ scp -r my-directory caen:project-1
{% endhighlight %}

# Downloading files from CAEN

Just put the arguments to `scp` in the reverse order to download from CAEN:

{% highlight sh %}
$ scp -r caen:project-1/my-directory my-directory
{% endhighlight %}

# Mounting CAEN as if it were a local drive

You can use `sshfs` ("SSH filesystem") to access files over SSH
as if they were on your local computer.

Linux users: just `apt-get install sshfs` or whatever it is you usually do.

OS X users:

 1. Ensure you have Homebrew installed. You can get it from
    [brew.sh](http://brew.sh).

 2. Install `osxfuse` by running this command in your terminal: `brew install
    osxfuse`.  Homebrew should install it for you and give you output like
this:

        The new osxfuse file system bundle needs to be installed by the root user:

          sudo /bin/cp -RfX something...
          sudo chmod +s something...

    Copy each of the two commands which were outputted in your terminal and run
them.
 3. Install `sshfs` by running `brew install sshfs`.

Now you can use `sshfs`. Open up the terminal and navigate to the place where
you want to make the virtual folder show up. For example:

    $ cd ~/Desktop

Make a new folder to hold the contents of your CAEN directory. (You can use any
empty folder, so feel free to reuse this folder between uses, or use a
differently-named folder.)

    $ mkdir caen-drive

Then mount CAEN using this command. This will prompt you for your CAEN password.

    $ sshfs caen: caen-drive

<aside class="aside-warning"><p>

This assumes you have an SSH alias called <code>caen</code>. Just like with
<code>scp</code>, you'll use the colon syntax to specify a remote directory. In
this case, we want to mount our home directory, so there's nothing after the
colon. However, you cannot omit the colon.

</p></aside>

<aside class="aside-warning"><p>

You may get a warning about kext and filesystems not being signed or so on. You
can safely ignore such warnings.

</p></aside>

Now you should be able to browse that folder and see the contents of your CAEN
home directory. When you're done, you can disconnect with this command:

    $ umount caen-drive

<aside class="aside-warning"><p>

That does not say "unmount". Read it again.

</p></aside>

Caveats:

  * If you lose internet connectivity, you'll be disconnected from CAEN.
    Unfortunately, this includes putting your laptop to sleep. To reconnect,
you'll have to run `umount` and `sshfs` again.
  * Object files and executables compiled on CAEN probably won't work on your
    local computer, and vice-versa. If you get weird errors about linking, try
running `make clean` and then recompiling.
