#ifndef AST_HH
#define AST_HH

#include <llvm/IR/Value.h>
#include <string>
#include <vector>

struct LLVMCompiler;

/**
Base node class. Defined as `abstract`.
*/
struct Node {
    enum NodeType {
        BIN_OP, INT_LIT, STMTS, ASSN, DBG, IDENT, TERN, IF_ELSE 
    } type;

    enum DataType {
        INT, SHORT, LONG
    } data_type;

    virtual std::string to_string() = 0;
    virtual llvm::Value *llvm_codegen(LLVMCompiler *compiler) = 0;
    virtual ~Node() {}
    
};

/**
    Node for list of statements
*/
struct NodeStmts : public Node {
    std::vector<Node*> list;

    NodeStmts();
    void push_back(Node *node);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for binary operations
*/
struct NodeBinOp : public Node {
    enum Op {
        PLUS, MINUS, MULT, DIV
    } op;

    Node *left, *right;

    NodeBinOp(Op op, Node *leftptr, Node *rightptr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for integer literals
*/
struct NodeInt : public Node {
    long value;

    NodeInt(long val);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for variable assignments
*/
struct NodeDecl : public Node {
    std::string identifier;
    Node *expression;

    NodeDecl(std::string id, std::string dataType, Node *expr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for `dbg` statements
*/
struct NodeDebug : public Node {
    Node *expression;

    NodeDebug(Node *expr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

/**
    Node for idnetifiers
*/
struct NodeIdent : public Node {
    std::string identifier;

    NodeIdent(std::string ident);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeAssign : public Node {
    std::string identifier;
    Node *expression;

    NodeAssign(std::string id, Node *expr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeTernary : public Node {
    Node * conditionExpression;
    Node * trueExpression;
    Node * falseExpression;

    NodeTernary(Node *conditionExpr, Node *trueExpr, Node *falseExpr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

struct NodeIfElse : public Node {
    Node * conditionExpression;
    Node * trueExpression;
    Node * falseExpression;

    NodeIfElse(Node *conditionExpr, Node *trueExpr, Node *falseExpr);
    std::string to_string();
    llvm::Value *llvm_codegen(LLVMCompiler *compiler);
};

#endif