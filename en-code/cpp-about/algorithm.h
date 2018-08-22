#ifndef ALGORITHM_H
#define ALGORITHM_H

#include <ctime>

class Algorithm {
public:
	Algorithm();
	~Algorithm();
	void bubble_sort(int* arr, int count);
	void quick_sort(int* arr, size_t left, size_t right);
	void algorithm_begin();
	int algorithm_end();
private:
	clock_t t;
};

#endif