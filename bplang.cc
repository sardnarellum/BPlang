#include <iostream>
#include <fstream>
#include <string>
#include "Parser.h"

using namespace std;



void input_handler( ifstream& in, int argc, char* argv[] );

int main( int argc, char* argv[] )
{
    ifstream in;
    input_handler( in, argc, argv );
    Parser pars( in );
    pars.parse();
    return 0;
}

void input_handler( ifstream& in, int argc, char* argv[] )
{
    if( argc < 2 )
    {
        cerr << "SOURCE ERROR: No source file. Enter the filename as argument." << endl;
        exit(1);
    }
    in.open( argv[1] );
    if( !in )
    {
        cerr << "SOURCE ERROR: \"" << argv[1] << "\" is not found." << endl;
        exit(1);
    }
}
