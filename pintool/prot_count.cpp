#include "pin.H"
#include <iostream>
#include <map>
#include <set>
#include <vector>
#include <algorithm>
#include <iomanip>

using namespace std;

int main(int argc, char *argv[]) {
    PIN_InitSymbols();
    if (PIN_Init(argc, argv))
        return 1;
    PIN_StartProgram();
    return 0;
}
