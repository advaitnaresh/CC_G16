//basic program

/*Compiler construction
lab1*/

//Case 1:
#def TEN 10
dbg TEN+TEN;

//Case 2:
#def STATEMENTS let a = 5; \
let x = a * 16; \
dbg a + b * x

let b = 10;
STATEMENTS;

//Case 3:
#def NOBODY
dbg NOBODY;

//Case 4:
#def ABC 4
#def DEF ABC + 5
#def GHI ABC * DEF
dbg GHI;

//Case 5:
#def ABC 1
dbg ABC;
#def ABC 15
dbg ABC;

/*Case 6:
#def ABC 2
#undef ABC
dbg ABC; */

/* Case 7: */
#def DEBUG 10
let y = 5;
#ifdef DEBUG
dbg y;
#endif

/* Case 8: */   
// Doesnt display anything
#def DEBUG 10
let m = 50;
#ifdef DEBUGtwo
dbg m;          
#endif

/*Case 9: */
let xerr=20;
#ifdef DEBUGll
dbg xerr;
#elif DEBUG

dbg 2*xerr;
#endif


/* Case 10: */
#def DEBUG 10
let xin = 5;
#undef DEBUG
#ifdef DEBUG
dbg xin;
#endif


// Successfully Giving an error

/*This should print the following

20

805

1

21

1
15

error

5 

Nothing displayed

40

Nothing displayed

*/