---
title: I don't want to install ruby on windows
category: tips
tags: docker github-pages
---

I find it terrible difficult to serve github pages locally.
Their setup prompts you to style and compile via Jekyll, a ruby tool,
which suddenly flings you into install make, and compiling various c++ dependencies.

Apparently this is a very error prone process on Windows, and I keep getting into installing 
a major eco-system, and have to try several times to figure out why this attempt failed with some
obscure warning. To further injure my pride, the entire install process is soley to compile and preview
my github pages before publishing them on Github, I'd really prefer to stay as far away as possible from ruby.

So, how to fix. Seems others have already solved my problem, just use Docker, and find a presetup image for
the exact purpose, and voila, an easily repeated process that's machine and platform independent and let's me
remove keep all the shit away from my environment variables, and local system.

