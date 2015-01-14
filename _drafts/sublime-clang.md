---
layout: post
title: Code-Completion in Sublime Text
subtitle: Apparently some of you use Sublime Text, so I asked a friend
  how to set up code-completion.
permalink: /sublime-clang/
---

This is a guest post from Alex Chojnacki ([thealex@umich.edu][alex]), who took
EECS 281 with me, and has worked extensively with a Sublime Text development
environment for 281.

  [alex]: mailto:thealex@umich.edu

# Introduction

All in all, this should take about an hour total.

This guide is for Mac OS X users only.

Here’s a workflow for those of us who love Sublime, but miss the code completion
elements of IDE’s. The solution is a plugin and a short list of dependencies.

Things you will need (install in this order):

  * Sublime Text 2 (this will not work for Sublime Text 3):
    [http://www.sublimetext.com/2](http://www.sublimetext.com/2)

  * Package Control for Sublime Text 2 (everyone should get this if they use
    Sublime): [https://packagecontrol.io/installation#st2](https://packagecontrol.io/installation#st2)

  * Homebrew: [http://brew.sh/](http://brew.sh/)

  * SublimeClang: In Package Control, search "SublimeClang" and select the
    package (it should be the only one named this --- if it is not, you may be
using Sublime Text 3).

  * Custom, compartmentalized, and up-to-date version of the GNU Compiler
    Collection (or "GCC") install supporting C++11. (We'll use GCC 4.9): First
type `brew tap homebrew/versions` into the terminal and hit enter. My output
looked like this:

        …

        theProfessional$ brew tap homebrew/versions
        Cloning into '/usr/local/Library/Taps/homebrew/homebrew-versions'...
        remote: Counting objects: 2693, done.
        remote: Total 2693 (delta 0), reused 0 (delta 0)
        Receiving objects: 100% (2693/2693), 884.52 KiB | 0 bytes/s, done.
        Resolving deltas: 100% (1562/1562), done.
        Checking connectivity... done.
        Tapped 171 formulae

        …

    Easy! The next thing you want to type is `brew install gcc49` This will
install `gcc` 4.9.2 and a few of its dependencies. These aren’t large files, but
they do take a while to download/install, so be prepared to keep your computer
powered and connected to the internet. The following dependencies will install
automatically: `gmp4` (2.8 minutes for me), `mpfr2` (1 minute), `libmpc08` (30
seconds), `pkg-config` (half a second), and `cloog018` (15 seconds). Then, the
main installation of `gcc49` will start. This took my computer 31 minutes.

    I list the times here just so you understand that it takes /some/ time. Time will carry based on internet connection and how zippy your computer is. Here was the output at the end of the installation process:

        …

        ==> Installing gcc49
        ==> Downloading http://ftpmirror.gnu.org/gcc/gcc-4.9.2/gcc-4.9.2.tar.bz2
        ######################################################################## 100.0%
        ==> Patching
        ==> ../configure --build=x86_64-apple-darwin14.0.0 --prefix=/usr/local/Cellar/gc
        ==> make bootstrap
        ==> make install
        🍺  /usr/local/Cellar/gcc49/4.9.2_1: 1138 files, 164M, built in 31.4 minutes
        theProfessional$ []

        …

    We’re almost finished! After the install is done, you'll want to try and
compile a C++ program using your new fancy GNU compiler. I recommend compiling a
simple "Hello World" on your desktop, but regardless of what you compile, make
sure to use the following command to do it: `g++-4.9 helloWorld.cpp -v`

The -v flag will provide verbose output, allowing us to see the paths to the gcc49 install’s libraries. This is important because we need to tell SublimeClang where to find these libraries! It will also produce a ton of other output that is very scary. Do not be alarmed by the wall of text! We will be looking for a few lines of text- specifically the ones between “#include “<…>” search starts here:” and “End of search list.”

Mine looked like this:
…
/usr/local/Cellar/gcc49/4.9.2_1/lib/gcc/4.9/gcc/x86_64-apple-darwin14.0.0/4.9.2/../../../../../../include/c++/4.9.2
 /usr/local/Cellar/gcc49/4.9.2_1/lib/gcc/4.9/gcc/x86_64-apple-darwin14.0.0/4.9.2/../../../../../../include/c++/4.9.2/x86_64-apple-darwin14.0.0
 /usr/local/Cellar/gcc49/4.9.2_1/lib/gcc/4.9/gcc/x86_64-apple-darwin14.0.0/4.9.2/../../../../../../include/c++/4.9.2/backward
 /usr/local/Cellar/gcc49/4.9.2_1/lib/gcc/4.9/gcc/x86_64-apple-darwin14.0.0/4.9.2/include
 /usr/local/include
 /usr/local/Cellar/gcc49/4.9.2_1/include
 /usr/local/Cellar/gcc49/4.9.2_1/lib/gcc/4.9/gcc/x86_64-apple-darwin14.0.0/4.9.2/include-fixed
 /usr/include
 /System/Library/Frameworks
 /Library/Frameworks
...

Those are the paths we need to give to SublimeClang! So after you search through the output in the terminal and nab these lines, you’ll want to open up Sublime Text 2 and navigate to the menu bar at the top. Next, click Sublime Text 2 > Preferences > Package Settings > SublimeClang > Settings-User

After clicking, you’ll be presented a blank file. This is part of what’s known as  a JSON file, and it’s what sublime uses to keep track of settings. Here’s what you need to put in it in order for SublimeClang to compile your project properly.

{
    "options":[
    // Any flag you would normally add in your compile command can be added here as shown. Create an unused variable and uncomment “-Wall”!
    // "-Wall",
    // "-Wno-unused-variable",

    "-I/usr/local/Cellar/gcc49/4.9.2_1/lib/gcc/4.9/gcc/x86_64-apple-darwin14.0.0/4.9.2/../../../../../../include/c++/4.9.2",
    "-I/usr/local/Cellar/gcc49/4.9.2_1/lib/gcc/4.9/gcc/x86_64-apple-darwin14.0.0/4.9.2/../../../../../../include/c++/4.9.2/x86_64-apple-darwin14.0.0",
    "-I/usr/local/Cellar/gcc49/4.9.2_1/lib/gcc/4.9/gcc/x86_64-apple-darwin14.0.0/4.9.2/../../../../../../include/c++/4.9.2/backward",
    "-I/usr/local/Cellar/gcc49/4.9.2_1/lib/gcc/4.9/gcc/x86_64-apple-darwin14.0.0/4.9.2/include",
    "-I/usr/local/include",
    "-I/usr/local/Cellar/gcc49/4.9.2_1/include",
    "-I/usr/local/Cellar/gcc49/4.9.2_1/lib/gcc/4.9/gcc/x86_64-apple-darwin14.0.0/4.9.2/include-fixed",
    "-I/usr/include",
    "-I/System/Library/Frameworks",
    "-I/Library/Frameworks"
    ],

    "additional_language_options":
    {
        "c++" :[
        "-std=c++11"
        ],
        "c": [],
        "objc": [],
        "objc++": []
    }
}

You can see the dependencies revealed from earlier are now shown in quotes with an "I-“ and a comma separating each one. Obviously, these are just my file paths. Yours could be different. The section at the bottom “additional_language_options” can be copied directly from this article.

Save the settings file and close it.

We’re done with all the installation! You should be able to open your helloWorld.cpp from earlier and add something incorrect. Save the file (command + s) and watch the errors pop up in the console below! Taking the semicolon off the end or using a vector without including <vector> should be enough to throw an error.

Now, here’s why we installed OS X Fuse. Some of you may have realized by now that we’re using a local compiler. This means that your files must be local to your machine. Many people use the plugin SFTP to get their files from CAEN into Sublime that way, and while SFTP is all fine and dandy- it compartmentalizes and separates your project files. This means that if main.cpp includes foo.h, SublimeClang won’t be able to link the two files. This is where OS X Fuse helps us out. With OS X Fuse, we can sync our CAEN Directory to our local machine and make changes to the files that will be reflected when we SSH back into CAEN. This means that gcc49 and SublimeClang can give us basic tips locally, while still being able to compile and test remotely on CAEN. YAY WORKFLOWS!

So here’s how you use OS X Fuse. Create an empty folder wherever you like and call is something like “CAEN” or “CAEN_mirror”- the name is arbitrary. Just keep the folder empty. Now, open up your terminal and navigate to the directory. Mine is on my desktop, so “cd ~/Desktop” does the job for me.

Next, you’ll type the following into the terminal: “sshfs <uniquename>@login.engin.umich.edu: <name of your CAEN_mirror type folder here>"

You will then be prompted for your password and then BAM! Your CAEN from filesystem accessible from your desktop as if it were networked drive!

When you're done working on your files in CAEN, always run "umount <your CAEN_mirror type file>" to unmount the drive before closing your laptop. Disconnecting from the internet can cause problems.

This means that you can open projects with Sublime Text 2 and have them link and compile correctly- allowing you access to autocompletion for the entire Standard Library, as well as anything you have in other included files!

There’s also a neat trick you can do to not have to type “<uniqename>@login.engin.umich.edu” every time. (Props to Waleed for showing me this)

Head back to the terminal and go to your home directory. "cd ~” will work. Enter "vim .ssh”. Navigate to “config” and press enter. Now, hit “i” to enable insert mode in Vim. Then add the following lines:

Host CAEN
  HostName login.engin.umich.edu
  User <uniquename here>

Then, press escape to exit insert mode and hit “:” (shift + semicolon) and type “wq” + enter. There! You’ve now shorthanded your SSH login to one short line. Both "ssh CAEN” and “sshfs CAEN: CAEN_mirror” will work as if you had typed out the whole hostname and user combination.


A few notes:
A good internet connection goes a long way. When you work on files directly in the CAEN_mirror folder, your sublime will beach-ball (loading rainbow wheel) waiting for the sync/compile to occur. If you're connected to the university wifi, this tends to be instantanious. Otherwise it may take a second or two. 

This next one is a little important. ALWAYS LOAD THE CAEN DRIVE BEFORE SUBLIME, AND (try to) ALWAYS umount BEFORE SHUTTING OFF THE COMPUTER. Basically, when you launch sublime, it'll try to reload your files in the location it saw them last, and if the location doesn't exist anymore, it loads a blank file with the name name and save target. If you open sublime before mounting, mount, then accidentally save the file (or autosave, as some people have save_on_focus_lost enabled- you know if you do, as this is not a default option) then the file /may/ be overwritten with a blank one. Sometimes it happens, sometimes sublime realizes a more updated version of the file has appeared and fails to write. In my expience, this only ever happened to me once, even though I've made the mistake multiple times. I've been able to recreate it at least once, so I have to mention that it CAN happen but won't if you follow the proceadure, and failing that, it's still unlikely.
