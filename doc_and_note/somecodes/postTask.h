#pragma once
#ifndef _POSTTASK_H_
#define _POSTTASK_H_
#include "type.h"

class TaskRun {
public:
	TaskRun();
	~TaskRun();
	void foo();
	void addTask(int num);
	void run();
private:
	boost::asio::io_service ios;
	int sumNum;
};

/*--------------------------------*/
class TaskFileSystem {
public:
	TaskFileSystem(const char* cPath);
	~TaskFileSystem();
	void async_dir(boost::asio::io_service& io, boost::filesystem::directory_iterator& di);
	void post();
	void run();
private:
	boost::asio::io_service ios;
	boost::filesystem::path pa;
	boost::system::error_code ec;
	boost::filesystem::directory_iterator di;
	int num;
};
#endif // !_POSTTASK_H_
