%option noyywrap

%{
    #include "parser.hh"
    #include <stdio.h>
    #include<iostream>
    #include <map>
    #include <string>
    using namespace std;
    std::map<std::string,std::string> defines;
    char one = '1';
    string recent;
    int defCheck=0;
    int undefCheck = 0;
    extern int yyerror(std::string msg);

%}

%x MULTICOMMENT
%option noyywrap

%%

\/\*                     { BEGIN(MULTICOMMENT); }
<MULTICOMMENT>[^*]*      { /* Removing Multiline Comments */ }
<MULTICOMMENT>\*\/       { BEGIN(INITIAL); }
"#def"    { defCheck =1;}
"#undef"  { undefCheck = 1;}
"//".* { /*This is a single line comment */ }
"+"       { return TPLUS; }
"-"       { return TDASH; }
"*"       { return TSTAR; }
"/"       { return TSLASH; }
";"       { {return TSCOL;}}
"("       { return TLPAREN; }
")"       { return TRPAREN; }
"="       { return TEQUAL; }
"dbg"     { return TDBG; }
"let"     { return TLET; }
[0-9]+    { if(defCheck == 2){defines[recent] = std::string(yytext);defCheck = 0;} else{yylval.lexeme = std::string(yytext); return TINT_LIT; }}
[\n]      {if(defCheck==2){defCheck=0; defines[recent] = "1";}}
[a-zA-Z]+ { if(undefCheck == 1){undefCheck = 0; defines.erase(std::string(yytext));}
            else if(defCheck==1){defCheck=2; recent = std::string(yytext);} 
            else if(defines.count(std::string(yytext))){yylval.lexeme = defines[std::string(yytext)]; return TINT_LIT;}
            else{yylval.lexeme = std::string(yytext); return TIDENT; }}
[ \t\n]   { /* skip */ }
.         { yyerror("unknown char"); }

%%

std::string token_to_string(int token, const char *lexeme) {
    std::string s;
    switch (token) {
        case TPLUS: s = "TPLUS"; break;
        case TDASH: s = "TDASH"; break;
        case TSTAR: s = "TSTAR"; break;
        case TSLASH: s = "TSLASH"; break;
        case TSCOL: s = "TSCOL"; break;
        case TLPAREN: s = "TLPAREN"; break;
        case TRPAREN: s = "TRPAREN"; break;
        case TEQUAL: s = "TEQUAL"; break;
        
        case TDBG: s = "TDBG"; break;
        case TLET: s = "TLET"; break;
        
        case TINT_LIT: s = "TINT_LIT"; s.append("  ").append(lexeme); break;
        case TIDENT: s = "TIDENT"; s.append("  ").append(lexeme); break;
    }

    return s;
}