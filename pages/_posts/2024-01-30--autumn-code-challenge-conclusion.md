---
title: "Autumn Code Challenge (Conclusion)"
category: challenges
tags: programming, architecture
published: false
---

Challenge hereby completed. Yay! Success! :)

This was a lengthy, slow burning project I had a lot of fun with. It never really
got to the point of feeling like a chore, and the next thing I worked on kept
popping up as an interesting itch I couldn't help but scratch.

The catalyst was the simple cell simulation 'game' of **Conway's Game of Life**.
  
You can find the full the prompt
[here](https://tugend.github.io/challenges/2023/07/28/autumn-code-challenge.html)
the code with a more technical commentary
[here](https://github.com/tugend/autumn-challenge-2023).

10/10, I already look forward to revisiting this again. 🙂

![Game screenshots](/assets/2024-02-12--autumn-code-challenge/games-screenshot.png)

## Learnings

Process-wise I went with 'As Simple as Possible, but No Simpler (rule 1)' and
style-wise I leaned heavily into functional programming, i.e. immutability and
statelessness, expressions over statements etc. which lead to a surprising
amount of interesting difficulties.

### Javascript 

* How to structure and handle none-linear javascript dependencies, i.e. the game
  needs to notify the dom render, and the dom render needs to call the game
  without making the code unreadable spaghetti. It's possible without a
  framework, but you have to keep a stiff upper lip and be real clear about
  responsibilities.

![script files](/assets/2024-02-12--autumn-code-challenge/wwwroot-files.png)

* I didn't want to jump straight into Javascript classes since the code get's
  pretty verbatim with everything prefixed by `this.`. I also decided that
  keeping as much as possible out of the global scope was pretty mandatory
  though. I ended up journeying from a quick start with old-school local scoped
  Javascript and into modern browser native modules, very much helped along in
  the refactor by the JSDoc types I introduced along the way (see the next bullet).

* Keeping it as simple as possible I forwent a bundler/compiler and was pretty
  happy with how far I got. A major pain point when complexity increased was
  types and static checks (none), but to my surprise the loose and somewhat
  verbatim JSDOCs (types are defined in comments) turned out to be very adequate
  to the task. Not quite as nice as Typescript, e.g. way worse support for
  refactoring, and feels a bit more optional and loose. So I'd call it an
  interesting lightweight alternative.

* I learned that we now have full browser support for [nested CSS
  styles](https://caniuse.com/css-nesting), and [Javascript
  modules](https://caniuse.com/es6-module). Yay!

    ```css
    // nested styles in vanilla css, no longer the domain of Sass/Less!
    #controls {
        font-size: 18px;
        > .btn { // 👈 #controls > .btn
            cursor: pointer;
            &:hover { // 👈 #controls > .btn:hover
                font-weight: bold;
            }
        }
    }
    ```

    ```js
    // local scoped modules with import / export out of the box in vanilla js!
    import UrlClient from "./url-client.mjs";

    const main = async () => {
      ...
    }

    export default main;
    ```

    ```html
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
    <html lang="en">
    <head>
    ...
    </head>
    <body>
    <main>
        <h1>Conways Game of Life</h1>
        <div id="conway"></div>
    </main>
    </body>

    <script type="module"> <!--👈--> 
        import main from "./scripts/main.mjs";
        await main();
    </script>
    </html>
    ```

### C#

* Visual end-to-end-tests, turned out you can write some pretty nice and simple
  code using a general purpose image library and Selenium. It was quite a
  delight to skip the complicated framework finagling and just bootstrap the
  thing. Prior experiences had lead me to believe it was pretty much mandatory
  to depend on some kind of framework on top of Selenium and then another
  framework or extension to access visual comparisons - or use a cloud based
  service.

  I made pretty simple setup that starts the server in a separate process, then
  runs the browser-based tests and takes screenshots, saves the screenshots
  under the test name, and compares them to any existing screenshots that should
  match. A visual difference breaks the test and both the failing screenshot and
  a diff image is automatically saved. To reset you just delete the images you
  want to reset.

* I also had a bit of fun with processes, how to make sure they're cleaned up
  correctly, how to start them and access the error output ect. Turned out it
  was a lot simpler than setting up some test config to reuse the assembly
   startup since I didn't need to setup any dependency injection overrides for
  tests. It actually leaves me wondering if I do that too often. The alternative
  also turned out to be a fair bit more difficult to make work with Selenium.

* I had some fun experiments with how functional I could go, and I feel I found
  a new level to what was possible in C#. For example, rather than make a
  classic OOP Game object with methods, I made a set of
  stateless methods, one per file and the game engine ended up being just the
  composition root for these individually independent methods. 
  
  Whether this approach applies at higher complexities I'm not sure, but I
  really like the strong separation of concern this yielded. I can't help but
  think how much easier it'd be to work with compared to the spaghetti I know
  from bigger projects (readability, extensibility, testability, correctness).


  ![tests](/assets/2024-02-12--autumn-code-challenge/visual-tests--tests.png)

  ![visual-output](/assets/2024-02-12--autumn-code-challenge/visual-tests--diffs.png)

