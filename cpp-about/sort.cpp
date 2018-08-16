#include <iostream>
#include "timedes.h"
using namespace std;


int main() {
	srand((unsigned)time(NULL));
	timedes timed;
	for(int i = 0; i < 1000000000; i++)
		rand();
	cout << endl;
	long dif = timed.getdifclock();
	int difsecond = timed.getdifclockseconds();
	cout << "---------dif-----" << dif << "-----dif seconds---" << difsecond << endl;
	return 0;
}