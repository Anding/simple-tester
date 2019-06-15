\ simple-tester is a unit tester intended for embedded systems or other simple targets
\ based on the ANS Forth version of John Hayes' Forth ttester
\
\ simple-tester requires
\ (i)    a numeric output device (e.g. a 4 character 7-segment LCD)
\ (ii)   a system halt instruction
\ (iii ) the forth word DEPTH

\ The usage format has been changed from ttester with the intention of being more "forth-like"
\ T{ run-a-module-of-code }T x1 x2 ... xn ==
\ T{ and }T bracket the code being tested
\ x1, x2, ... xn are the expected outputs
\ == is the assert instruction that performs the comparison and indicates the result

\ simple-tester uses a hash algorithm to compare inputs and outputs rather than cell by cell comparison
\ possible advantages
\ (i) 	2 cells only of RAM required
\ (ii)	testing limited only by stack depth
\ (iii) simple comparison code without stack gynmastics, easy to write the necessary code words
\ (iv)	fast, advantageous for POST applications
\ possible disadvantages
\ (i)	false negatives - hash collissions may pass a test that should actually have been failed

\ on an embedded system the following words are expected to be available as code words
\ (thus testing of a new forth system can begin even before the system knows how to compile new word definitions)
\ words are coded here in forth for development and to give the pseudocode for translation into code

\ report the test number to a numeric output device
: T.
	.			\ for gforth
;

\ halt the system
: halt
	quit		\ for gforth
;

\ compute h1 by hashing x1 and h0
: hash ( x1 h0 -- h1)
	swap 1+ xor									\ hash may be a simple function initially but upgraded later
;												\ to improve collision detection and test reliability

\ hash n items from the stack and return the hash code
: hash-n ( x1 x2 ... xn n -- h)
	0 >R										\ put the initial hash value on the return stack
	BEGIN
		dup 0 >									\ confirm at least one value to process
	WHILE
		swap R> hash >R
		1-
	REPEAT
	drop R>
;

variable Tcount
variable Tdepth

\ start testing
: Tstart
0 Tcount !
;

\ start a unit test
: T{ ( N R:d)
	Tcount @ 1+ dup T. Tcount !					\ increment and report the test number
	depth Tdepth !								\ save the stack depth before the module runs
;

\ finish a unit test, y1, y2 ... yn are the actual outputs
: }T ( N y1 y2 ... yn R:d -- N hy R:d)
	depth Tdepth @ -	( N y1 y2 ... yn Ny)	\ Ny  = no. outputs created by running the module
	hash-n				( N hy)
	depth Tdepth !		( N hy)					\ save the stack depth before the expected outputs
;

\ compare actual output with expected output
: == ( N h x1 x2 ... xn R:d -- N)
	depth Tdepth @ -	( N hy x1 x2 .. xn Nx)	\ Nx = no. outputs expected
	hash-n				( N hy hx)
	= 0= IF halt THEN							\ hash codes didn't match, stop the system
;

\ signal end of testing
: Tend  ( N --)
	65535 T.									\ some at-a-glance value to indicate successful completion
;
