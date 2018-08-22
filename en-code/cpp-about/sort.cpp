#include <iostream>
#include "timedes.h"
#include "algorithm.h"
using namespace std;


int main() {
	srand((unsigned)time(NULL));
	timedes timed;
	Algorithm algo;
	int* array = new int[10000000];
	for(int i = 0; i < 10000000; i++)
		array[i] = rand();
	cout << endl;
	for(int i = 0; i < 10; i++)
		cout << "---" << array[i];
	long dif = timed.getdifclock();
	int difsecond = timed.getdifclockseconds();
	cout << "---------dif-----" << dif << "-----dif seconds---" << difsecond << "---sizeof array---" << sizeof(array) << sizeof(array[0]) << endl;
	algo.algorithm_begin();
	//algo.bubble_sort(array, 100000);
	algo.quick_sort(array, 0, 10000000-1);
	difsecond = algo.algorithm_end();
	for(int i = 0; i < 10; i++)
		cout << "++++" << array[i];
	cout << "-----dif seconds---" << difsecond << endl;
	delete []array;
	return 0;
}