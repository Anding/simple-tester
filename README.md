# simple-tester

A small Forth test package based on the ANS Forth version of `ttester.f`.

See the fully-commented code files for further explanation

Tests retain the compact postfix form:

```forth
Tstart
T{ 1 2 + }T 3 ==
Tend
```

`==` records a mismatch and continues, reporting the failing test number.
`Tend` prints one authoritative desktop result:

```text
TEST-PASS 1
```

or:

```text
TEST-FAIL 1 OF 4
```

The test file does not control interpreter lifetime. In particular, it does
not need `QUIT` or `bye`, which makes the same test suitable for interactive
use and persistent process control.
