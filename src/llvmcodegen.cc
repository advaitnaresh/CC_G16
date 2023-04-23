#include "llvmcodegen.hh"
#include "ast.hh"
#include <iostream>
#include <llvm/Support/FileSystem.h>
#include <llvm/IR/Constant.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/GlobalValue.h>
#include <llvm/IR/Verifier.h>
#include <llvm/Bitcode/BitcodeWriter.h>
#include "llvm/Support/Debug.h"
#include <vector>

#define MAIN_FUNC compiler->module.getFunction("main")

/*
The documentation for LLVM codegen, and how exactly this file works can be found
ins `docs/llvm.md`
*/

void LLVMCompiler::compile(Node *root) {
    /* Adding reference to print_i in the runtime library */
    // void printi();
    FunctionType *printi_func_type = FunctionType::get(
        builder.getVoidTy(),
        {builder.getInt32Ty()},
        false
    );
    Function::Create(
        printi_func_type,
        GlobalValue::ExternalLinkage,
        "printi",
        &module
    );
    /* we can get this later 
        module.getFunction("printi");
    */

    /* Main Function */
    // int main();
    FunctionType *main_func_type = FunctionType::get(
        builder.getInt32Ty(), {}, false /* is vararg */
    );
    Function *main_func = Function::Create(
        main_func_type,
        GlobalValue::ExternalLinkage,
        "main",
        &module
    );

    // create main function block
    BasicBlock *main_func_entry_bb = BasicBlock::Create(
        *context,
        "entry",
        main_func
    );

    // move the builder to the start of the main function block
    builder.SetInsertPoint(main_func_entry_bb);

    root->llvm_codegen(this);

    // return 0;
    builder.CreateRet(builder.getInt32(0));
}

void LLVMCompiler::dump() {
    outs() << module;
}

void LLVMCompiler::write(std::string file_name) {
    std::error_code EC;
    raw_fd_ostream fout(file_name, EC, sys::fs::OF_None);
    WriteBitcodeToFile(module, fout);
    fout.flush();
    fout.close();
}

//  ┌―――――――――――――――――――――┐  //
//  │ AST -> LLVM Codegen │  //
// └―――――――――――――――――――――┘   //

// codegen for statements
Value *NodeStmts::llvm_codegen(LLVMCompiler *compiler) {
    Value *last = nullptr;
    for(auto node : list) {
        last = node->llvm_codegen(compiler);
    }

    return last;
}

Value *NodeDebug::llvm_codegen(LLVMCompiler *compiler) {
    Value *expr = expression->llvm_codegen(compiler);

    Function *printi_func = compiler->module.getFunction("printi");
    compiler->builder.CreateCall(printi_func, {expr});
    // DEBUG_WITH_TYPE("llvm_codegen", dbgs() << "Debug: << expression->to_string() << ");
    return expr;
}

Value *NodeInt::llvm_codegen(LLVMCompiler *compiler) {
    return compiler->builder.getInt32(value);
}

Value *NodeBinOp::llvm_codegen(LLVMCompiler *compiler) {
    Value *left_expr = left->llvm_codegen(compiler);
    Value *right_expr = right->llvm_codegen(compiler);

    switch(op) {
        case PLUS:
        return compiler->builder.CreateAdd(left_expr, right_expr, "addtmp");
        case MINUS:
        return compiler->builder.CreateSub(left_expr, right_expr, "minustmp");
        case MULT:
        return compiler->builder.CreateMul(left_expr, right_expr, "multtmp");
        case DIV:
        return compiler->builder.CreateSDiv(left_expr, right_expr, "divtmp");
    }
}


Value *NodeDecl::llvm_codegen(LLVMCompiler *compiler) {
    Value *expr = expression->llvm_codegen(compiler);

    IRBuilder<> temp_builder(
        &MAIN_FUNC->getEntryBlock(),
        MAIN_FUNC->getEntryBlock().begin()
    );

    
    AllocaInst *alloc = temp_builder.CreateAlloca(compiler->builder.getInt32Ty(), 0, identifier);

    compiler->locals[identifier] = alloc;

    compiler->builder.CreateStore(expr, alloc);

    return expr;
}

Value *NodeIdent::llvm_codegen(LLVMCompiler *compiler) {
    AllocaInst *alloc = compiler->locals[identifier];

    // if your LLVM_MAJOR_VERSION >= 14
    return compiler->builder.CreateLoad(compiler->builder.getInt32Ty(), alloc, identifier);
}

Value *NodeAssign::llvm_codegen(LLVMCompiler *compiler) {
     Value *expr = expression->llvm_codegen(compiler);

    IRBuilder<> temp_builder(
        &MAIN_FUNC->getEntryBlock(),
        MAIN_FUNC->getEntryBlock().begin()
    );

    //assign to variable
    AllocaInst *alloc = compiler->locals[identifier];

    compiler->locals[identifier] = alloc;

    compiler->builder.CreateStore(expr, alloc);

    return expr;
}

Value *NodeTernary::llvm_codegen(LLVMCompiler *compiler){
    Value *cond = conditionExpression->llvm_codegen(compiler);
    Value *truExpr = trueExpression->llvm_codegen(compiler);
    Value *falExpr = falseExpression->llvm_codegen(compiler);

    IRBuilder<> temp_builder(
        &MAIN_FUNC->getEntryBlock(),
        MAIN_FUNC->getEntryBlock().begin()
    );

    return compiler->builder.CreateSelect(cond, truExpr, falExpr);
    // return nullptr;
}
Value *NodeIfElse::llvm_codegen(LLVMCompiler *compiler) {
    Value *cond = conditionExpression->llvm_codegen(compiler);

    //convert cond to a bool by comparing equal to 0.0
    cond = compiler->builder.CreateICmpNE(
        cond,
        compiler->builder.getInt32(0),
        "ifcond"
    );

    Function *function = compiler->builder.GetInsertBlock()->getParent();

    BasicBlock *then_bb = BasicBlock::Create(*compiler->context, "ifBB", function);
    BasicBlock *else_bb = BasicBlock::Create(*compiler->context, "elseBB", function);
    BasicBlock *merge_bb = BasicBlock::Create(*compiler->context, "mergeBB", function);

    // if the condition is true, jump to the then block, else jump to the else block
    compiler->builder.CreateCondBr(cond, then_bb, else_bb);

    // then block
    compiler->builder.SetInsertPoint(then_bb);
    Value *then_value = trueExpression->llvm_codegen(compiler);
    compiler->builder.CreateBr(merge_bb);

    then_bb = compiler->builder.GetInsertBlock();

    // else block
    // function->insert(function->end(), else_bb);
    
    compiler->builder.SetInsertPoint(else_bb);
    Value *else_value = falseExpression->llvm_codegen(compiler);
    compiler->builder.CreateBr(merge_bb);

    else_bb = compiler->builder.GetInsertBlock();

    // // merge block
    // function->insert(function->end(), merge_bb);
    compiler->builder.SetInsertPoint(merge_bb);

    // `getType() == V->getType() && "All operands to PHI node must be the same type as the PHI node!
    // PHINode to execute between then and else blocks based on condition with any type
    PHINode *phi_node = compiler->builder.CreatePHI(then_value->getType(), 2, "ifelse");
    phi_node->addIncoming(then_value, then_bb);
    phi_node->addIncoming(else_value, else_bb);


    return phi_node;
    // return nullptr;
}

#undef MAIN_FUNC