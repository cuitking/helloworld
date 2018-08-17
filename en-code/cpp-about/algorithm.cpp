#include "algorithm.h"

Algorithm::Algorithm() {
	
}

Algorithm::~Algorithm() {
	
}

void Algorithm::algorithm_begin() {
	this->t = clock();
}

int Algorithm::algorithm_end() {
	clock_t t_now = clock();
	long t_dif = t_now - this->t;
	return (int)(t_dif/CLOCKS_PER_SEC);
}

void Algorithm::bubble_sort(int* arr, int count) {
	for (int i = 0; i < count - 1; i++) {
		for (int j = 0; j < count - i - 1; j++) {
			if (arr[j] > arr[j+1]) {
				int temp = arr[j]; arr[j] = arr[j+1]; arr[j+1] = temp;
			}
		}
	}
}
