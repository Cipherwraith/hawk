# Hawk

Transform text from the command-line using Haskell expressions. Similar to [awk](http://cm.bell-labs.com/cm/cs/awkbook/index.html), but using Haskell as the text-processing language.


## Examples

The Haskell expression `(!! 1)` takes the second element from a list. Using Hawk to `--map` this expression over all input lines, we can extract the second column of the output of `ps`.

```bash
> ps -eo 'pid,ppid,comm' | hawk -m '(!! 1)' | head -n3
PPID
20509
188
```

That behaviour was similar to the standard unix tool [`cut`](http://en.m.wikipedia.org/wiki/Cut_%28Unix%29). Many other standard command-line tools can be easily approximated using [other short Haskell expressions](http://www.haskell.org/haskellwiki/Simple_Unix_tools).

By adding custom function definitions to `~/.hawk/prelude.hs`, it is easy to `--apply` much more advanced manipulations to the input.

```bash
> ps -eo 'pid,ppid,comm' | hawk -a 'fmap (drop 2) . tree (!! 0) (!! 1) . tail'
[...]
login
  -bash
    ps
    hawk
```
([prelude.hs](doc/tree/prelude.hs))

The above asks `ps` to output three columns: the process id, the parent process id, and the command name. Then, Hawk runs the output through three more steps. First, the headers row is stripped off by `tail`. Next, the remaining rows are arranged as a tree, using the first two columns as keys and parent keys. Finally, `drop 2` removes those two columns from the output, resulting in a tree of command names.

For more details, see the [documentation](doc/README.md).


## Installation

To install the development version, clone this repository and use `cabal install` or `cabal-dev install` to compile Hawk and its dependencies. Cabal installs the binary to `~/.cabal/bin/hawk`, while cabal-dev installs it to `./cabal-dev/bin/hawk`. The first run will create a `~/.hawk/prelude.hs` skeleton from which you can import more modules and implement your custom transformations.
