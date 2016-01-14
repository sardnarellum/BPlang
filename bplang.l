%option noyywrap c++ yylineno

%{
#include "Parserbase.h"
%}

DIGIT   [0-9]
WS      [ \t\n]
LETTER  [a-zA-Z]
ID		{LETTER}+({DIGIT}*|"-"*|"_"*|{LETTER}*)*
TIME	(([0-1][0-9])|(2[0-3]))":"[0-5][0-9]

%%


"**"[^\n]*\n		// skip comments

{TIME}				return Parser::TIME;
{DIGIT}+    		return Parser::NATURAL;

PROGRAM  			return Parser::PROGRAM;
VALTOZOK:			return Parser::VALTOZOK;
UTASITASOK:			return Parser::UTASITASOK;
PROGRAM_VEGE		return Parser::PROGRAMVEGE;
HA		 			return Parser::HA;
AKKOR				return Parser::AKKOR;
KULONBEN			return Parser::KULONBEN;
HA_VEGE				return Parser::HAVEGE;
CIKLUS 				return Parser::CIKLUS;
AMIG				return Parser::AMIG;
CIKLUS_VEGE			return Parser::CIKLUSVEGE;
KI:					return Parser::KI;
BE:					return Parser::BE;
IDO					return Parser::IDO;
EGESZ				return Parser::EGESZ;
LOGIKAI				return Parser::LOGIKAI;
IGAZ				return Parser::IGAZ;
HAMIS				return Parser::HAMIS;
SKIP				return Parser::SKIP;

ora					return Parser::HOUR;
perc				return Parser::MINUTE;

":="	        	return Parser::ASSIGN;
"="	        		return Parser::EQUAL;
"<"					return Parser::LESS;
">"					return Parser::GREATER;
"+"     		   	return Parser::PLUS;
"*"					return Parser::MULTIPLY;
"/"					return Parser::DIVIDE;
"%"					return Parser::MOD;
ES 					return Parser::ES;
VAGY				return Parser::VAGY;
NEM					return Parser::NEM;
"("     	    	return Parser::LBRACE;
")"     	    	return Parser::RBRACE;

{ID}				return Parser::IDENTIFIER;

{WS}+       // skip whitespaces

.           {
                std::cerr << "[ERROR at line " << lineno() << "] Unknown token: '" << yytext << "'" << std::endl;
                exit(1);
            }

%%
