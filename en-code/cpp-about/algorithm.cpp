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
	//第一层循环,遍历整个数组
	for (int i = 0; i < count - 1; i++) {
		// 第二层循环截止到除去i个元素后的前一个元素
		for (int j = 0; j < count - i - 1; j++) {
			if (arr[j] > arr[j+1]) {
				int temp = arr[j]; arr[j] = arr[j+1]; arr[j+1] = temp;
			}
		}
	}
}



/*快速排序
1)算法
A.从序列中找出一个元素作为基准；
B.从新组织序列，所有小于基准的元素都位于基准的左侧，所有大于基准的元素都位于基准的右侧，与基准相等的元素可位于基准的任一侧；
C.以递归的方式分别对左右两个分组进行排序。
2)评价
平均时间复杂度O(NlogN)，不稳定。理论上如果每次都能做到均匀分组，会得到的最快的排序速度。
*/	
void Algorithm::quick_sort(int* data, size_t left, size_t right) {
	size_t p = (left + right) / 2;
	int pivot = data[p];
	
	for (size_t i = left, j = right; i < j;) {
		while (!(i >= p || pivot < data[i]))
		i++;
		if (i < p) {
			data[p] = data[i];	
			p = i;
		}
		while (! (j <= p || data[j] < pivot))
		j--;
		if (j > p) {
			data[p] = data[j];	
			p = j;
		}
	}
	data[p] = pivot;
	if (p - left > 1)
		this->quick_sort(data, left, p - 1);
	if (right - p > 1)
		this->quick_sort(data, p + 1, right);
}
