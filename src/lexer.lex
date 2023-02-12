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
    int ignore_newline = 0;
    extern int yyerror(std::string msg);
    string debug;
    string defstr;

%}

%x MULTICOMMENT
%x MACRODEF
%option noyywrap

%%

\/\*                     { BEGIN(MULTICOMMENT); }
<MULTICOMMENT>[^*]*      { /* Removing Multiline Comments */ }
<MULTICOMMENT>\*\/       { BEGIN(INITIAL); }


"#def"    { defCheck =1; defstr =""; BEGIN(MACRODEF); }
<MACRODEF>[a-zA-Z]+      {debug = string(yytext); 
                                    if(defCheck == 1){
                                        defCheck = 2; 
                                        recent = std::string(yytext);
                                    }
                                    else if(defCheck == 3){
                                        defstr = defstr + std::string(yytext);
                                        defines[recent] = defstr;
                                    }
                                    }
<MACRODEF>" "           {debug = string(yytext); 
                        if(defCheck == 2){defCheck = 3;}
                        else if(defCheck == 3){defstr = defstr + " ";}}
<MACRODEF>";"           {debug = string(yytext); 
                        defstr = defstr + ";";}
<MACRODEF>"\\"           {ignore_newline = 1;}
<MACRODEF>[a-zA-Z0-9+-/=*]+         {debug = string(yytext); 
                                    if(defCheck == 3){
                                        defstr = defstr + std::string(yytext);
                                        defines[recent] = defstr;
                                    }}
<MACRODEF>[\n]           {if(ignore_newline == 0){
                                debug = string(yytext); 
                                if(defCheck == 2){
                                    defCheck = 0; 
                                    defines[recent] = "1";
                                    BEGIN(INITIAL);
                                }
                                else{
                                    defCheck = 0;
                                    BEGIN(INITIAL);
                                    }}
                            else{
                                ignore_newline = 0;
                            }
                            }

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
[0-9]+    {yylval.lexeme = std::string(yytext); return TINT_LIT; }
[a-zA-Z]+ { 
    debug = string(yytext);
        if(undefCheck == 1){
            undefCheck = 0; defines.erase(std::string(yytext));} 
        else if(defines.count(std::string(yytext))){
            debug = string(yytext);
            string str = defines[std::string(yytext)];
            int n = str.length();
            int i = n - 1;
            while(i >= 0){
                unput(str[i]);
                i--;
            }
        }
        else{
            yylval.lexeme = std::string(yytext); return TIDENT; }}
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

    int len = debug.length();
    /* for (int i = 0; i < len; i++)
        printf("%d ", debug[i]); */

    s.append(" ++ ").append(debug);

    return s;
}