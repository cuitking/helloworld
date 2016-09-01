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

/*------------------------------*/
class TaskWithWork {
public:
	TaskWithWork();
	~TaskWithWork();
	void foo();
	void post();
	void run();
	void thd_fun();

private:
	boost::asio::io_service ios;
	boost::asio::io_service::work* works;
	boost::system::error_code ec;
};

/*--------------------------------*/
class BaseNet {
public:
	BaseNet(int ports);
	~BaseNet();
	void Async_Session(boost::asio::ip::tcp::socket* iosocket);
	void WaitConnect();
private:
	boost::asio::io_service ios;
	boost::asio::ip::tcp::endpoint endpoint;
	boost::asio::ip::tcp::acceptor acceptor;
	std::vector<boost::asio::ip::tcp::socket*> socks;
};

/*------------------------------------------*/
class BaseServer {
public:
	BaseServer(int ports);
	~BaseServer();
	void session(boost::asio::ip::tcp::socket* sock, const boost::system::error_code& error);
	void handler_write(boost::asio::ip::tcp::socket* sock, const boost::system::error_code& error, size_t bytes_transferred);
	void handler_read(boost::asio::ip::tcp::socket* sock, const boost::system::error_code& error, size_t bytes_transferred);
	void run();
private:
	boost::asio::io_service ios;
	boost::asio::ip::tcp::endpoint endpoint;
	boost::asio::ip::tcp::acceptor acceptor;
	std::vector<boost::asio::ip::tcp::socket*> socks;
	char data[MAXLENBUF];
};
/* -----------asio 7 boost.coroutine stackless---------*/
class Stackless
{
public:
	Stackless();
	~Stackless();
	int foo(boost::asio::coroutine& ct);
	void check();
private:
	boost::asio::coroutine ct;
};


class BoostCor 
{
public:
	BoostCor(int ports);
	~BoostCor();
	void handle(boost::asio::coroutine ct, boost::asio::ip::tcp::socket* sock, const boost::system::error_code& error, size_t bytes_transferred);
	void session(boost::asio::ip::tcp::socket* sock, const boost::system::error_code& error);
	void Run();
private:
	boost::asio::io_service ios;
	boost::asio::ip::tcp::endpoint endpoint;
	boost::asio::ip::tcp::acceptor acceptor;
	char data[MAXLENBUF];
};
#endif // !_POSTTASK_H_
