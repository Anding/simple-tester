# simple-tester
A simple FORTH test package intended for embedded systems based on the ANS FORTH version of ttester.f

See the fully-commented code files for further explanation

Example session
```
 >gforth
Gforth 0.7.2, Copyright (C) 1995-2008 Free Software Foundation, Inc.
Gforth comes with ABSOLUTELY NO WARRANTY; for details type `license'
Type `bye' to exit
include simple-tester.fs redefined hash   ok
include test1.fs 1 2 3 4 65535  ok
include test2.fs 1
include test3.fs 1 2 3 4
```
