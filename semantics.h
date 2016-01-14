#ifndef SEMANTICS_H
#define SEMANTICS_H

#include <string>
#include <iostream>
#include <cstdlib>
#include <sstream>
#include <map>

enum expr_type { Natural, Bool, Time, Module };

struct expr_decl
{
    int 		line;
    expr_type 	etype;
    std::string code;
    expr_decl(const int &l, const expr_type &t, const std::string &c) : line(l), etype(t), code(c) {}
    expr_decl() {}
};

struct instr_decl
{
	int 		line;
	std::string code;
	instr_decl(const int &l, const std::string &c) : line(l), code(c) {}
};

#endif //SEMANTICS_H
