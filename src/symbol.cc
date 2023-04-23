#include "symbol.hh"

bool SymbolTable::contains(std::string key) {
    return (table.find(key) != table.end()) || (parent != nullptr && parent->contains(key));
}

void SymbolTable::insert(std::string key) {
    table.insert(key);
}