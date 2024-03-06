---
title: "Autumn Code Challenge (Conclusion)"
category: challenges
tags: creativity architecture software-tests javascript csharp
published: true
---

Challenge hereby completed. Yay! Success! :)

This was a lengthy, slow burning project I had a lot of fun with. It never
really got to the point of feeling like a chore, and the next thing I worked on
kept popping up as an interesting itch I couldn't help but scratch.

The catalyst was the simple cell simulation 'game' of **Conway's Game of Life**.
  
You can find the initial prompt
[here](https://tugend.github.io/challenges/2023/07/28/autumn-code-challenge-prompt.html)
and the code with a more technical commentary
[here](https://github.com/tugend/autumn-challenge-2023).

10/10, I already look forward to revisiting this again. 🙂

![Game
screenshots](/assets/2024-02-12--autumn-code-challenge/games-screenshot.png)

## Learnings

Process-wise I went with '*As Simple as Possible, but No Simpler*' (rule 1, The
Rules of Programming, Zimmerman) and style-wise I leaned heavily into functional
programming such as immutability and statelessness, expressions over statements.
which lead to a surprising number of interesting difficulties.

Here's the list of my most significant areas of interest split in a Javascript
and a C# part. 

### Javascript 

* **Architecture**: How to structure and handle none-linear javascript
  dependencies, i.e. the game needs to notify the dom render, and the dom render
  needs to call the game \- without making the code unreadable spaghetti. It's
  possible without a framework, but you have to keep a stiff upper lip and be
  real clear about responsibilities. I was pretty happy with the result. To do
  more would likely require either a framework, a dive into game programming
  patterns.  

![script files](/assets/2024-02-12--autumn-code-challenge/wwwroot-files.png)

* **Scopes and classes**: I wanted to avoid classic object oriented programming
  since Javascript classes feel very verbatim and having everything prefixed by
  `this.` is a chore to maintain. On the other hand, I also wanted to avoid
  polluting the global namespace, which is a well recognized anti-pattern. 
  
  Instead I journeying from a fast start with old-school function scoped
  'modules' and from there refactored the code base towards modern ES6 modules,
  very much helped along in the refactor by the JSDoc types I introduced along
  the way (see the next bullet).

* **Types**: Keeping it as simple as possible I forwent a bundler/compiler and
  was pretty happy with how far I got. A major pain point when complexity
  increased was types and static checks (none), but to my surprise the loose and
  somewhat verbatim JSDOCs (types are defined in comments) turned out to be very
  adequate to the task. Not quite as nice as Typescript, e.g. way worse support
  for refactoring, and feels a bit more fragile. So I'd classify it an useful
  lightweight alternative.

* **Browser Support**: I learned that we now have full browser support for
  [nested CSS styles](https://caniuse.com/css-nesting), and [Javascript
  modules](https://caniuse.com/es6-module). Yay!

    ```css
    // nested styles in vanilla css, no longer the domain of Sass/Less!
    #controls {
        font-size: 18px;
        > .btn {
            cursor: pointer;
            &:hover {
                font-weight: bold;
            }
        }
    }
    ```

    ```js
    // local scoped modules with import and export out of the box in vanilla js!
    import UrlClient from "./url-client.mjs";

    const main = async () => {
      ...
    }

    export default main;
    ```

    ```html
    ...
    <body>
    <main>
        <h1>Conways Game of Life</h1>
        <div id="conway"></div>
    </main>
    </body>

    <script type="module">
        import main from "./scripts/main.mjs";
        await main();
    </script>
    ...
    ```

### C#

* **Visual end-to-end-tests**: It turned out you can write some pretty nice and
  simple code using a general purpose image library and Selenium. It was quite a
  delight to skip the complicated framework finagling and just bootstrap the
  thing. Prior experiences had lead me to believe it was pretty much mandatory
  to depend on some kind of framework on top of Selenium and then another
  framework or extension to access visual comparisons - or use a cloud based
  service.

  I made setup that starts the game server on a separate process, then runs the
  browser-based tests and takes screenshots, saves the screenshots under the
  test name, and compares them to any existing screenshots that should match.
  The test fails on any visual differences and both the failing screenshot and a
  diff are automatically saved. To reset you just delete the images you want to
  reset.

  ![tests](/assets/2024-02-12--autumn-code-challenge/visual-tests--tests.png)

  ![visual-output](/assets/2024-02-12--autumn-code-challenge/visual-tests--diffs.png)

* **Processes**: I had a bit of fun with processes, how to make sure they're
  cleaned up correctly, how to start them and access the error output ect.
  Turned out it was a lot simpler than setting up some test config to reuse the
   assembly startup since I didn't need to setup any dependency injection
  overrides for tests. It actually leaves me wondering if I do that too often.
  The alternative also turned out to be a fair bit more difficult to make work
  with Selenium.

* **Functional**: I had some fun experiments with how functional I could go, and
  I feel I found a new level to what is possible in C#. For example, rather
  than make a classic OOP Game object with methods, I made a set of stateless
  methods, one per file and the game engine ended up being just the composition
  root for these individually independent methods. 
  
  Whether this approach applies at higher complexities I'm not sure, but I
  really like the strong separation of concern this yielded. I can't help but
  think how much easier it'd be to work with compared to the spaghetti I know
  from bigger projects (readability, extensibility, testability, correctness).

  ![functional-compositions](/assets/2024-02-12--autumn-code-challenge/function-compositions.png)

## Resources

* Blog Prompt: [tugend.github.io](https://tugend.github.io/challenges/2023/07/28/autumn-code-challenge-prompthtml).
* Code: [github.com/tugend](https://github.com/tugend/autumn-challenge-2023)