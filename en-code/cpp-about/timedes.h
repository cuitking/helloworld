#ifndef TIMEDES_H
#define TIMEDES_H

#include <cstdlib>
#include <ctime>

class timedes
{
public:
	timedes();
	~timedes();
	void update();
	char* timeformat();
	void initclock();
	long getdifclock();
	int getdifclockseconds();
private:
	time_t rawtime;
	clock_t t;
};


#endif