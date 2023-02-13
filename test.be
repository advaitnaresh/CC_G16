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
// Successfully Giving an error

/*This should print the following

20

805

1

21

1
15

error

*/