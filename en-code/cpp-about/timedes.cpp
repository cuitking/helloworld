#include "timedes.h"


timedes::timedes() {
	time(&rawtime);
	t = clock();
}

timedes::~timedes() {}

void timedes::update() {
	time(&rawtime);
}

char* timedes::timeformat() {
	this->update();
	return ctime(&this->rawtime);
}

void timedes::initclock() {
	t = clock();
}

long timedes::getdifclock() {
	clock_t t_now = clock();
	long t_dif = t_now - this->t;
	return t_dif;
}

int timedes::getdifclockseconds() {
	clock_t t_now = clock();
	long t_dif = t_now - this->t;
	return (int)(t_dif/CLOCKS_PER_SEC);
}