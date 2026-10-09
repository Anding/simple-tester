\ simple-tester is a small Forth unit tester
\ based on the ANS Forth version of John Hayes' Forth ttester

\ simple-tester requires the forth words DEPTH and TYPE

\ The usage format has been changed from ttester with the hope/intention of being more "forth-like"
\ T{ module-of-code }T x1 x2 ... xn ==
\ T{ and }T brackets the code being tested
\ x1, x2, ... xn are the expected outputs
\ == compares the actual and expected outputs, reports a failure, and continues
\ so that Tend can report the complete result

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
variable Tfailures

\ unit test code words to be suitably implemented on the target system
\ reference implementations here in Forth
\ ===========================================================================================================

\ start testing
: Tstart
	0 Tcount !
	0 Tfailures !
;

\ start a unit test
: T{ ( )
	Tcount @ 1+ Tcount !							\ increment the test number
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
	= 0= IF
		1 Tfailures +!
		cr s" TEST-FAIL " type Tcount @ . cr
	THEN
;

\ signal end of testing
: Tend  ( --)
	cr
	Tfailures @ IF
		s" TEST-FAIL " type Tfailures @ .
		s" OF " type Tcount @ . cr
	ELSE
		s" TEST-PASS " type Tcount @ . cr
	THEN
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
    c-addr u r/o open-file abort" cannot open test file" -> fileid
    fileid file-size nip drop -> bytes
    bytes allocate drop -> caddr
    caddr bytes fileid read-file abort" cannot read test file"
    caddr swap hashS
    caddr free drop
    fileid close-file drop
;
    
