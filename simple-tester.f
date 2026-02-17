\ simple-tester is a unit tester intended for embedded systems or other hardware targets
\ based on the ANS Forth version of John Hayes' Forth ttester

\ the purpose of simple-tester is
\ (i)	to allow unit testing on targets with limited resources and
\ (ii)	to allow testing as early on as possible in the lifecycle of a new forth system,
\		even before the system knows how to compile new word defintions
\
\ simple-tester requires
\ (i)    a numeric output device (e.g. a seven-segment display)
\ (ii)   a system halt instruction
\ (iii ) the forth word DEPTH

\ The usage format has been changed from ttester with the hope/intention of being more "forth-like"
\ T{ module-of-code }T x1 x2 ... xn ==
\ T{ and }T brackets the code being tested
\ x1, x2, ... xn are the expected outputs
\ == is the assert instruction that performs the comparison and halts the system on the first fail
\ if a test either fails to complete execution or the actual and expected outputs do not match, then
\ the numeric output device will show the number of the test that failed

\ simple-tester uses a hash algorithm to compare inputs and outputs rather than cell by cell comparison
\ possible advantages
\ (i) 	2 cells only of RAM required for operation
\ (ii)	testing scope is limited only by stack depth
\ (iii) 	no stack gynmastics, easy to write the necessary code words in brief assembly language
\ (iv)	fast, advantageous for power-on-self-test-applications
\ disadvantage
\ (i)		false positive risk - hash collissions may allow a test to pass that should actually have been failed

\ the following words are expected to be available as code words on the target system, other words are utility words
\ Tstart Tend T{ T} ==

\ utility words called by the unit test code words
\ ===========================================================================================================

\ report the test number to a numeric output device, such as a seven-segment display
: T.
	.			\ for a desktop Forth
;

\ halt the system
: halt-system
	quit		\ for a desktop Forth
;

\ compute h1 by hashing x1 and h0
: hash ( x1 h0 -- h1)
	31 * swap 13 + xor					\ hash may be any simple function initially but upgraded later
;												\ make sure it is not symmetric since stack reversal is a common error

\ hash n items from the stack and return the hash code
: hash-n ( x1 x2 ... xn n -- h)
	0 >R										\ put the initial hash value on the return stack
	BEGIN
		dup 0 >								\ confirm at least one value to process
	WHILE
		swap R> hash >R
		1-
	REPEAT
	drop R>
;

variable Tcount
variable Tdepth

\ unit test code words to be suitably implemented on the target system
\ reference implementations here in Forth
\ ===========================================================================================================

\ start testing
: Tstart
	0 Tcount !
	0 T.
;

\ start a unit test
: T{ ( )
	Tcount @ 1+ dup T. Tcount !					\ increment and report the test number
	depth Tdepth !										\ save the stack depth before the module runs
;

\ finish a unit test,
: }T ( y1 y2 ... yn -- hy) 						\ y1, y2 ... yn are the actual outputs
	depth Tdepth @ -	( y1 y2 ... yn Ny)		\ Ny  = no. outputs created by running the module
	hash-n				( hy)							\ hy = hash value of the actual outputs
	depth Tdepth !		( hy)							\ save the stack depth before the expected outputs
;

\ compare actual output with expected output
: == ( hy x1 x2 ... xn --)
	depth Tdepth @ -	( hy x1 x2 .. xn Nx)		\ Nx = no. outputs expected
	hash-n				( hy hx)						\ hx = hash value of the expected outputs
	= 0= IF halt-system THEN						\ hash codes didn't match, stop the system
;

\ signal end of testing
: Tend  ( --)
	65535 ( 0xFFFF) T.								\ some at-a-glance value to indicate successful completion
;

\ extension words, perhaps for desktop systems
\ reference implementations here in Forth
\ ===========================================================================================================

\ hash a string to a single value on stack
: hashS ( c-addr u -- h)
	swap 2dup + swap ( u end+1 start)
		?do												\ Let h0 = u
			i c@ ( h_i x) swap hash ( h_j)			\ j = i + 1
		loop
;

\ hash a file to a single value on stack
: hashF { c-addr u | fileid bytes caddr -- h }
    c-addr u r/o open-file IF halt-system THEN -> fileid
    fileid file-size nip drop -> bytes
    bytes allocate drop -> caddr
    caddr bytes fileid read-file IF halt-system THEN 
    caddr swap hashS
    caddr free drop
    fileid close-file drop
;
    
