# simple-tester

A small Forth test package based on the ANS Forth version of `ttester.f`.

See the fully-commented code files for further explanation

Tests retain the compact postfix form:

```forth
Tstart
T{ 1 2 + }T 3 ==
Tend
```

`==` prints the passing test number, or records a mismatch and prints
`FAIL@ <number>`. `Tend` prints the totals followed by one authoritative
desktop result:

```text
TESTS PASSED 1
TESTS FAILED 0
REGRESSION PASSED ***********************
```

or:

```text
TESTS PASSED 3
TESTS FAILED 1
REGRESSION FAILED !!!!!!!!!!!!!!!!!!!!!!!
```

The test file does not control interpreter lifetime. In particular, it does
not need `QUIT` or `bye`, which makes the same test suitable for interactive
use and persistent process control.
