%baseclass-preinclude "semantics.h"

%lsp-needed

%token <text> NATURAL
%token <text> TIME
%token <text> HOUR
%token <text> MINUTE
%token PROGRAM	
%token VALTOZOK		
%token UTASITASOK		
%token PROGRAMVEGE			
%token HA 				
%token AKKOR			
%token KULONBEN		
%token HAVEGE			
%token CIKLUS 			
%token AMIG			
%token CIKLUSVEGE	
%token BE			
%token KI
%token IDO			
%token EGESZ			
%token LOGIKAI	
%token ASSIGN	
%token LBRACE
%token RBRACE

%token <text> IDENTIFIER

%token IGAZ			
%token HAMIS				
%token SKIP

%left VAGY
%left ES	
%left NEM	
%left EQUAL
%left LESS GREATER
%left PLUS
%left MULTIPLY DIVIDE MOD


%type <expr>	expression
%type <instr>	declarationblock
%type <instr>	declarationlist
%type <instr>	declaration
%type <instr>	statementblock
%type <instr>	statementlist
%type <instr>	statement
%type <instr>	assignment
%type <instr>	cread
%type <instr>	cwrite
%type <instr>	conditional
%type <instr>	loop

%union
{
    std::string 	*text;
    expr_decl 		*expr;
    instr_decl		*instr;
}

%%

start:
	prefp declarationblock statementblock postp
	{

        std::cout << std::string("") +
        "global main\n"
        "extern be_egesz\n" +
        "extern be_logikai\n" +
        "extern ki_egesz\n" +
        "extern ki_logikai\n" +
        $2->code +
        $3->code +
        "ret\n";

		delete $2;
		delete $3;
	}

;

prefp:
	PROGRAM IDENTIFIER
	{
		delete $2;
	}
;

postp:
	PROGRAMVEGE
	{
	}
;

declarationblock:
	//empty
	{
		$$ = new instr_decl(d_loc__.first_line, "");
	}
|
	VALTOZOK declarationlist
	{
		$$ = new instr_decl($2->line, "\nsection .data\n" + $2->code);
		delete $2;
	}
;

declarationlist:
	declaration
	{
		$$ = new instr_decl($1->line, $1->code);
		delete $1;
	}
|
	declaration declarationlist
	{
		$$ = new instr_decl($1->line, $1->code + $2->code);
		delete $1;
		delete $2;
	}
;

declaration:
	EGESZ IDENTIFIER
	{
		if( symbols.count(*$2) > 0 )
		{
			std::stringstream ss;
			ss << *$2 << " is already declared as a variable at line " << symbols[*$2].line << ".";
			error( ss.str().c_str() );
		}

		symbols[*$2] = expr_decl( d_loc__.first_line, Natural,
			*$2 + ": dd 0\n"
		);

		$$ = new instr_decl(symbols[*$2].line, symbols[*$2].code);

		delete $2;
	}
|
	LOGIKAI IDENTIFIER
	{
		if( symbols.count(*$2) > 0 )
		{
			std::stringstream ss;
			ss << *$2 << " is already declared as a variable at line " << symbols[*$2].line << ".";
			error( ss.str().c_str() );
		}

		symbols[*$2] = expr_decl( d_loc__.first_line, Bool, 
			*$2 + ": db 0\n"
		);

		$$ = new instr_decl(symbols[*$2].line, symbols[*$2].code);

		delete $2;
	}
|
	IDO IDENTIFIER
	{
		if( symbols.count(*$2) > 0 )
		{
			std::stringstream ss;
			ss << *$2 << " is already declared as a variable at line " << symbols[*$2].line << ".";
			error( ss.str().c_str() );
		}

		symbols[*$2] = expr_decl( d_loc__.first_line, Time, 
			*$2 + ": dd 0\n"
		);

		$$ = new instr_decl(symbols[*$2].line, symbols[*$2].code);

		delete $2;
	}
;

statementblock:
	UTASITASOK statementlist
	{
		$$ = new instr_decl($2->line,
			"\nsection .text\nmain:\n" +
			$2->code
		);
		delete $2;
	}
;

statementlist:
	statement
	{
		$$ = new instr_decl($1->line, $1->code);
		delete $1;
	}
|
	statement statementlist
	{
		$$ = new instr_decl($1->line, $1->code + $2->code);

		delete $1;
		delete $2;
	}
;

statement:
	SKIP
	{
		$$ = new instr_decl(d_loc__.first_line, "");
	}
|
	assignment
	{
		$$ = new instr_decl($1->line, $1->code);

		delete $1;
	}
|
	cread
	{
		$$ = new instr_decl($1->line, $1->code);

		delete $1;
	}
|
	cwrite
	{
		$$ = new instr_decl($1->line, $1->code);

		delete $1;
	}
|
	loop
	{
		$$ = new instr_decl($1->line, $1->code);

		delete $1;
	}
|
	conditional
	{
		$$ = new instr_decl($1->line, $1->code);

		delete $1;
	}
;



assignment:
	IDENTIFIER ASSIGN expression
	{
		if( symbols.count(*$1) == 0 )
		{
			std::stringstream ss;
			ss << "Unknown identifier: " << *$1;
			error( ss.str().c_str() );
		}

		if( symbols[*$1].etype != $3->etype )
		{
			error( "Type mismatch in assignment." );
		}

		std::string reg = $3->etype != Bool ? "eax" : "al";

		$$ = new instr_decl(d_loc__.first_line, $3->code + "mov [" + *$1 + "], " + reg + "\n");

		delete $1;
		delete $3;
	}
;

cread:
	BE IDENTIFIER
	{
		if( symbols.count(*$2) == 0 )
		{
			std::stringstream ss;
			ss << "Unknown identifier: " << *$2;
			error( ss.str().c_str() );
		}

		std::string fun = symbols[*$2].etype == Natural ? "be_egesz" : "be_logikai";
		std::string reg = symbols[*$2].etype == Natural ? "eax" : "al";

        $$ = new instr_decl(
        	symbols[*$2].line,
            "call " + fun + "\n" +
            "mov [" + *$2 + "], " + reg + "\n"
        );

		delete $2;
	}
;

cwrite:
	KI expression
	{
		if ($2->etype == Time)
		{
			error( "Time expressions cannot be printed." );
		}

		std::string fun = $2->etype == Natural ? "ki_egesz" : "ki_logikai";
		std::string reg = $2->etype == Bool ? "movzx eax, al\npush eax\n" : "push eax\n";

		$$ = new instr_decl(
			d_loc__.first_line,
			$2->code +
			reg +
			"call " + fun + "\n" +
			"add esp, 4\n"
		);

		delete $2;
	}
;

loop:
	CIKLUS AMIG expression statementlist CIKLUSVEGE
	{
		if ($3->etype != Bool)
		{
			error( "Only boolean expression permitted in loop condition." );
		}

		std::stringstream ss;
		ss << "lab#" << Parser::labels++;

		std::string lstart = ss.str();

		ss.str("");
		ss << "lab#" << Parser::labels++;

		std::string lend = ss.str();

		$$ = new instr_decl(
			d_loc__.first_line,
			"\n" + lstart + ":\n" +
			$3->code +
			"cmp al, 1\n" +
			"jne near " + lend + "\n" +
			$4->code +
			"jmp " + lstart + "\n\n" +
			lend + ":\n"
		);

		delete $3;
		delete $4;
	}
;

conditional:
	HA expression AKKOR statementlist HAVEGE
	{
		if ($2->etype != Bool)
		{
			error( "Only boolean expression permitted in if statement's condition." );
		}

		std::stringstream ss;
		ss << "lab#" << Parser::labels++;

		std::string lend = ss.str();

		$$ = new instr_decl(
			d_loc__.first_line,
			$2->code +
			"cmp al, 1\n" +
			"jne near " + lend + "\n" +
			$4->code + "\n" +
			lend + ":\n"
		);

		delete $2;
		delete $4;
	}
|
	HA expression AKKOR statementlist KULONBEN statementlist HAVEGE
	{
		if ($2->etype != Bool)
		{
			error( "Only boolean expressions permitted in if statement's condition." );
		}

		std::stringstream ss;

		ss << "lab#" << Parser::labels++;
		std::string lstart = ss.str();
		ss.str("");

		ss << "lab#" << Parser::labels++;
		std::string lelse = ss.str();
		ss.str("");

		ss << "lab#" << Parser::labels++;
		std::string lend = ss.str();

		$$ = new instr_decl(
			d_loc__.first_line,
			"\n" + lstart + ":\n" +
			$2->code +
			"cmp al, 1\n" +
			"jne near " + lelse + "\n" +
			$4->code +
			"jmp " + lend + "\n\n" +
			lelse + ":\n" +
			$6->code + "\n" +
			lend + ":\n"
		);

		delete $2;
		delete $4;
		delete $6;
	}
;


expression:
	IDENTIFIER
	{
		if( symbols.count(*$1) == 0 )
		{
			std::stringstream ss;
			ss << "Unknown identifier: " << *$1;
			error( ss.str().c_str() );
		}

		std::string dest = symbols[*$1].etype != Bool ? "eax" : "al";

		$$ = new expr_decl(d_loc__.first_line, symbols[*$1].etype,
			"mov " + dest + ", [" + *$1 + "]\n"
		);

		delete $1;
	}
|
	NATURAL
	{
		$$ = new expr_decl(d_loc__.first_line, Natural, "mov eax, " + *$1 + "\n");

		delete $1;
	}
|
	TIME
	{
		$1->erase($1->begin() + 2);

		$$ = new expr_decl(d_loc__.first_line, Time, "mov eax, " + *$1 + "\n");

		delete $1;
	}
|
	HOUR LBRACE expression RBRACE
	{
		if ($3->etype != Time)
		{
			error( "ora(Time t) can take only Time parameters." );
		}

		$$ = new expr_decl(d_loc__.first_line, Natural,
			$3->code +
			"mov edx, 0\n" +
			"mov ebx, 100\n" +
			"div ebx\n"
		);
		delete $3;
	}
|
	MINUTE LBRACE expression RBRACE
	{
		if ($3->etype != Time)
		{
			error( "minute(Time t) can take only Time parameters." );
		}

		$$ = new expr_decl(d_loc__.first_line, Natural,
			$3->code +
			"mov edx, 0\n" +
			"mov ebx, 100\n" +
			"div ebx\n" +
			"mov eax, edx\n"
		);
		delete $3;
	}
|
	IGAZ
	{
		$$ = new expr_decl(d_loc__.first_line, Bool,
			"mov al, 1\n"
		);
	}
|
	HAMIS
	{
		$$ = new expr_decl(d_loc__.first_line, Bool,
			"mov al, 0\n"
		);
	}
|
	LBRACE expression RBRACE
	{
		$$ = new expr_decl(d_loc__.first_line, $2->etype, $2->code);

		delete $2;
	}
|
	NEM expression
	{
		if ($2->etype != Bool)
		{
			error( "Only Bool expressions can be negated." );
		}

		$$ = new expr_decl(d_loc__.first_line, $2->etype, $2->code + "xor al, 1\n");

		delete $2;
	}
|
	expression EQUAL expression
	{
		if ($1->etype != $3->etype)
		{
			error( "Type mismatch in equation." );
		}

		std::string regs = $1->etype == Natural ? "eax, ebx" : "al, bl";

		$$ = new expr_decl(d_loc__.first_line, Bool,
			$3->code +
			"push eax\n" +
			$1->code +
			"pop ebx\n" +
			"cmp " + regs + "\n" +
			"sete al\n"
		);

		delete $1;
		delete $3;
	}
|
	expression PLUS expression
	{
		if ($1->etype != Natural)
		{
			error( "The first argument of + is not a EGESZ." );
		}

		if ($3->etype != Natural)
		{
			error( "The second argument of + is not a EGESZ." );
		}

		$$ = new expr_decl(d_loc__.first_line, Natural,
			$3->code +
			"push eax\n" +
			$1->code +
			"pop ebx\n" +
			"add eax, ebx\n"
		);
		
		delete $1;
		delete $3;
	}
|
	expression MOD expression
	{
		if ($1->etype != Natural)
		{
			error( "The first argument of MOD is not a EGESZ." );
		}

		if ($3->etype != Natural)
		{
			error( "The second argument of MOD is not a EGESZ." );
		}

		$$ = new expr_decl(d_loc__.first_line, Natural,
			$3->code +
			"push eax\n" +
			$1->code +
			"pop ebx\n" +
			"mov edx, 0\n" +
			"div ebx\n" +
			"mov eax, edx\n"
		);
		
		delete $1;
		delete $3;
	}
|
	expression DIVIDE expression
	{
		if ($1->etype != Natural)
		{
			error( "The first argument of / is not a EGESZ." );
		}

		if ($3->etype != Natural)
		{
			error( "The second argument of / is not a EGESZ." );
		}

		$$ = new expr_decl(d_loc__.first_line, Natural,
			$3->code +
			"push eax\n" +
			$1->code +
			"pop ebx\n" +
			"mov edx, 0\n" +
			"div ebx\n"
		);
		
		delete $1;
		delete $3;
	}
|
	expression MULTIPLY expression
	{
		if ($1->etype != Natural)
		{
			error( "The first argument of * is not a EGESZ." );
		}

		if ($3->etype != Natural)
		{
			error( "The second argument of * is not a EGESZ." );
		}

		$$ = new expr_decl(d_loc__.first_line, Natural,
			$3->code +
			"push eax\n" +
			$1->code +
			"pop ebx\n" +
			"mul ebx\n"
		);
		
		delete $1;
		delete $3;
	}
|
	expression ES expression
	{
		if ($1->etype != Bool)
		{
			error( "The first argument of ES is not Boolean." );
		}

		if ($3->etype != Bool)
		{
			error( "The second argument of ES and is not Boolean." );
		}

		$$ = new expr_decl(d_loc__.first_line, Bool,
			$3->code +
			"push eax\n" +
			$1->code +
			"pop ebx\n" +
			"and al, bl\n" 
		);
		
		delete $1;
		delete $3;
	}
|
	expression VAGY expression
	{
		if ($1->etype != Bool)
		{
			error( "The first argument of OR is not Boolean." );
		}

		if ($3->etype != Bool)
		{
			error( "The second argument of OR is not Boolean." );
		}

		$$ = new expr_decl(d_loc__.first_line, Bool,
			$3->code +
			"push eax\n" +
			$1->code +
			"pop ebx\n" +
			"or al, bl\n" 
		);
		
		delete $1;
		delete $3;
	}
|
	expression LESS expression
	{
		if ($1->etype != Natural)
		{
			error( "The first argument of < is not a EGESZ." );
		}

		if ($3->etype != Natural)
		{
			error( "The second argument of < is not a EGESZ." );
		}

		$$ = new expr_decl(d_loc__.first_line, Bool,
			$3->code +
			"push eax\n" +
			$1->code +
			"pop ebx\n" +
			"cmp eax, ebx\n" +
			"setl al\n"
		);
		
		delete $1;
		delete $3;
	}
|
	expression GREATER expression
	{
		if ($1->etype != Natural)
		{
			error( "The first argument of > is not a EGESZ." );
		}

		if ($3->etype != Natural)
		{
			error( "The second argument of > is not a EGESZ." );
		}

		$$ = new expr_decl(d_loc__.first_line, Bool,
			$3->code +
			"push eax\n" +
			$1->code +
			"pop ebx\n" +
			"cmp eax, ebx\n" +
			"seta al\n"
		);
		
		delete $1;
		delete $3;
	}
;
