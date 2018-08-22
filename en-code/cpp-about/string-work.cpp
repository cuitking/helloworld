#include <iostream>
#include <string>
using namespace std;

int main(int argc, char* argv[]) {
	string s1, s2;
	cout << "input one string" << endl;
	cin >> s1;
	cout << "input second string" << endl;
	cin >> s2;
	if (s1 == s2) {
		cout << " first string equal second string" << endl;
	}
	else if(s1 > s2) {
		cout << " the biger string is :" << s1 << endl;
	}
	else if(s1 < s2) {
		cout << " the bigger string is :" << s2 << endl;
	}

	if (s1.size() == s2.size()) {
		cout << " first string length equal second string length" << endl;
	}
	else if(s1.size() > s2.size()) {
		cout << " the logger string is:" << s1 << endl;
	}
	else if(s1.size() < s2.size()) {
		cout << " the logger string is:" << s2 << endl;
	}
	return 0;

}