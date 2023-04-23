#include "ast.hh"

#include <string>
#include<iostream>
#include <vector>


NodeBinOp::NodeBinOp(NodeBinOp::Op ope, Node *leftptr, Node *rightptr) {
    type = BIN_OP;
    op = ope;
    left = leftptr;
    right = rightptr;

    if(leftptr->data_type == LONG && rightptr->data_type == LONG){
        data_type = LONG;
    }
    else if(leftptr->data_type == INT && rightptr->data_type == INT){
        data_type = INT;
    }
    else if(leftptr->data_type == SHORT && rightptr->data_type == SHORT){
        data_type = SHORT;
    }
}

std::string NodeBinOp::to_string() {
    std::string out = "(";
    switch(op) {
        case PLUS: out += '+'; break;
        case MINUS: out += '-'; break;
        case MULT: out += '*'; break;
        case DIV: out += '/'; break;
    }

    out += ' ' + left->to_string() + ' ' + right->to_string() + ')';

    return out;
}

NodeInt::NodeInt(long val) {
    type = INT_LIT;
    value = val;
    if(val <= 65535){
        data_type = SHORT;
    }
    else if(val <= 2147483647){
        data_type = INT;
    }
    else{
        data_type = LONG;
    }
}

std::string NodeInt::to_string() {
    return std::to_string(value);
}

NodeStmts::NodeStmts() {
    type = STMTS;
    list = std::vector<Node*>();
}

void NodeStmts::push_back(Node *node) {
    list.push_back(node);
}

std::string NodeStmts::to_string() {
    std::string out = "(begin";
    for(auto i : list) {
        out += " " + i->to_string();
    }

    out += ')';

    return out;
}

NodeDecl::NodeDecl(std::string id,std::string dataType, Node *expr) {
    type = ASSN;
    identifier = id;
    expression = expr;
    if(dataType == "int"){
        data_type = INT;
    }
    else if(dataType == "short"){
        data_type = SHORT;
    }
    else if(dataType == "long"){
        data_type = LONG;
    }

    if((expr->data_type == LONG && this->data_type == INT)){
        std::cerr << "Error: Cannot assign long to integer" << std::endl;
        exit(1);
    }
    else if((expr->data_type == LONG && this->data_type == SHORT)){
        std::cerr << "Error: Cannot assign long to short" << std::endl;
        exit(1);
    }
    else if((expr->data_type == INT && this->data_type == SHORT)){
        std::cerr << "Error: Cannot assign integer to short" << std::endl;
        exit(1);
    }
}

std::string NodeDecl::to_string() {
    std::string out = "(let (" + identifier + " ";
    switch(data_type) {
        case SHORT: out += "short"; break;
        case INT: out += "int"; break;
        case LONG: out += "long"; break;
    }

    out +=") " + expression->to_string() + ")";

    return out;
}

NodeDebug::NodeDebug(Node *expr) {
    type = DBG;
    expression = expr;
    this->data_type = expr->data_type;
}

std::string NodeDebug::to_string() {
    return "(dbg " + expression->to_string() + ")";
}

NodeIdent::NodeIdent(std::string ident) {
    identifier = ident;
}
std::string NodeIdent::to_string() {
    return identifier;
}


NodeAssign::NodeAssign(std::string id, Node *expr) {
    type = ASSN;
    identifier = id;
    expression = expr;
    if((expr->data_type == LONG && this->data_type != LONG) || (expr->data_type == INT && this->data_type == SHORT)){
        std::cout << "Error: Cannot assign " << expr->data_type << " to " << this->data_type << std::endl;
        exit(1);
    }
}

std::string NodeAssign::to_string() {
    return "(assign " + identifier + " " + expression->to_string() + ")";
}

NodeTernary::NodeTernary(Node *conditionExpr, Node *trueExpr, Node *falseExpr) {
    type = TERN;
    conditionExpression = conditionExpr;
    trueExpression = trueExpr;
    falseExpression = falseExpr;
}

std::string NodeTernary::to_string() {
    return "(?: " + conditionExpression->to_string() + " " + trueExpression->to_string() + " " + falseExpression->to_string() + ")";
}

NodeIfElse::NodeIfElse(Node *conditionExpr, Node *trueExpr, Node *falseExpr) {
    type = IF_ELSE;
    conditionExpression = conditionExpr;
    trueExpression = trueExpr;
    falseExpression = falseExpr;
}

std::string NodeIfElse::to_string() {
    return "(if-else " + conditionExpression->to_string() + " " + trueExpression->to_string() + " " + falseExpression->to_string() + ")";
}