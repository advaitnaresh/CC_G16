%define api.value.type { ParserValue }

%code requires {
#include <iostream>
#include <vector>
#include <string>

#include "parser_util.hh"
#include "symbol.hh"

}

%code {

#include <cstdlib>

extern int yylex();
extern int yyparse();

extern NodeStmts* final_values;

SymbolTable* symbol_table = new SymbolTable();
// symbol_table->parent = nullptr;

int yyerror(std::string msg);

}
%token TIF TELSE TLBRACE TRBRACE
%token TQN TCOL TPLUS TDASH TSTAR TSLASH
%token <lexeme> TINT_LIT TIDENT TTYPE
%token INT TLET TDBG
%token TSCOL TLPAREN TRPAREN TEQUAL

%type <node> Expr Stmt Rbrace Lbrace
%type <stmts> Program StmtList

%left TPLUS TDASH
%left TSTAR TSLASH

%%

Program :                
        { final_values = nullptr; }
        | StmtList 
        { final_values = $1; }
	    ;

StmtList : Stmt                
         { $$ = new NodeStmts(); $$->push_back($1); }
	     | StmtList Stmt 
         { $$->push_back($2); }
	     ;

Stmt : TLET TIDENT TCOL TTYPE TEQUAL Expr TSCOL
     {
        if(symbol_table->contains($2)) {
            // tried to redeclare variable, so error
            yyerror("tried to redeclare variable.\n");
        } else {
            symbol_table->insert($2);

            $$ = new NodeDecl($2, $4, $6);
        }
     }
     | TDBG Expr TSCOL
     { 
        $$ = new NodeDebug($2);
     }
     | TIDENT TEQUAL Expr TSCOL
     {
        if(symbol_table->contains($1)){
            $$ = new NodeAssign($1,$3);
        }else{
            yyerror("using undefined variable.\n");
        }
     }
     | TIF Expr Lbrace StmtList Rbrace TELSE Lbrace StmtList Rbrace
     {
        $$ = new NodeIfElse($2, $4, $8);
     }
     ;

Lbrace : TLBRACE
       {
            struct SymbolTable* new_table = new SymbolTable();
            new_table->parent = symbol_table;
            symbol_table = new_table;
            $$ = nullptr;
        }
       ;


Rbrace : TRBRACE
       {
            symbol_table = symbol_table->parent;
            $$ = nullptr;}
       ;


Expr : TINT_LIT               
     { $$ = new NodeInt(stoll($1)); }
     | TIDENT
     { 
        if(symbol_table->contains($1))
            $$ = new NodeIdent($1); 
        else
            yyerror("using undeclared variable.\n");
     }
     | Expr TPLUS Expr
     { $$ = new NodeBinOp(NodeBinOp::PLUS, $1, $3); }
     | Expr TDASH Expr
     { $$ = new NodeBinOp(NodeBinOp::MINUS, $1, $3); }
     | Expr TSTAR Expr
     { $$ = new NodeBinOp(NodeBinOp::MULT, $1, $3); }
     | Expr TSLASH Expr
     { $$ = new NodeBinOp(NodeBinOp::DIV, $1, $3); }
     | Expr TQN Expr TCOL Expr
     { $$ = new NodeTernary($1, $3, $5); } 
     | TLPAREN Expr TRPAREN { $$ = $2; }
     ;

%%

int yyerror(std::string msg) {
    std::cerr << "Error! " << msg << std::endl;
    exit(1);
}