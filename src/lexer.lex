%option noyywrap

%{
    #include "parser.hh"
    #include <stdio.h>
    #include <map>
    #include <string.h>
    std::map<std::string,std::string> defines;

    int defCheck=0;
extern int yyerror(std::string msg);

%}

%x MULTICOMMENT
%option noyywrap

%%

\/\*                     { BEGIN(MULTICOMMENT); }
<MULTICOMMENT>[^*]*      { /* Removing Multiline Comments */ }
<MULTICOMMENT>\*\/       { BEGIN(INITIAL); }

"#def"    { defCheck =1; return TLET;}
"//".* { /*This is a single line comment */ }
"+"       { return TPLUS; }
"-"       { return TDASH; }
"*"       { return TSTAR; }
"/"       { return TSLASH; }
";"       { return TSCOL; }
"("       { return TLPAREN; }
")"       { return TRPAREN; }
"="       { return TEQUAL; }
"dbg"     { return TDBG; }
"let"     { return TLET; }
[0-9]+    { yylval.lexeme = std::string(yytext); return TINT_LIT; }
[a-zA-Z]+ { if(defCheck==1){defCheck=2;} yylval.lexeme = std::string(yytext); return TIDENT; }
[ \t\n]   { /* skip */ if(defCheck==2){defCheck=0; return TEQUAL;} }
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