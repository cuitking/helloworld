#include <iostream>
#include "timedes.h"
using namespace std;


void bubble_sort(int* arr, int len) {
	int i, j;
	for (i = 0; i < len - 1; i++) {
		for (j = 0; j < len - 1 -i; j++) {
			if(arr[j] > arr[j+1]) {
				int temp = arr[j];
				arr[j] = arr[j+1];
				arr[j+1] = temp;
			}
		}
	}
}

int main() {
	srand((unsigned)time(NULL));
	timedes timed;
	int* array = new int[100000];
	for(int i = 0; i < 100000; i++)
		array[i] = rand();
	cout << endl;
	// for(int i = 0; i < 1000000; i++)
	// 	cout << "---" << array[i];
	long dif = timed.getdifclock();
	int difsecond = timed.getdifclockseconds();
	cout << "---------dif-----" << dif << "-----dif seconds---" << difsecond << "---sizeof array---" << sizeof(array) << sizeof(array[0]) << endl;
	timed.initclock();
	bubble_sort(array, 100000);
	// for(int i = 0; i < 10; i++)
	// 	cout << "++++" << array[i];
	dif = timed.getdifclock();
	difsecond = timed.getdifclockseconds();
	cout << "---------dif-----" << dif << "-----dif seconds---" << difsecond << endl;
	delete []array;
	return 0;
}