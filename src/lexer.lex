%option noyywrap

%{
#include "parser.hh"

#include <string>
#define MAX_SYMBOL_LENGTH 100
char symbol_name[MAX_SYMBOL_LENGTH + 1];

extern int yyerror(std::string msg);

%}

%x MULTICOMMENT
%option noyywrap

%%
"#def" {  
    int i = 0;
  char c;
  while ((c = getchar()) != EOF && c != '\n' && c != ' ' && i < MAX_SYMBOL_LENGTH) {
    symbol_name[i++] = c;
  }
  symbol_name[i] = '\0';
  printf("Symbol: %s\n", symbol_name);
}

\/\*                     { BEGIN(MULTICOMMENT); }
<MULTICOMMENT>[^*]*      { /* Removing Multiline Comments */ }
<MULTICOMMENT>\*\/       { BEGIN(INITIAL); }

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
[a-zA-Z]+ { yylval.lexeme = std::string(yytext); return TIDENT; }
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