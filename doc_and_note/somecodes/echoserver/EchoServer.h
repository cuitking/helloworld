#pragma once
#ifndef  _ECHOSERVER_H_
#define  _ECHOSERVER_H_

#include "type.h"
class session;
typedef boost::shared_ptr<session> session_ptr;

class session : public boost::enable_shared_from_this<session>
{
public:
	

	static session_ptr get_new_session(boost::asio::io_service& io_service);
	boost::asio::ip::tcp::socket& socket();
	~session();
	void start();

private:
	session(boost::asio::io_service& io_service);
	void handle_read(const boost::system::error_code& error, size_t bytes_transferred);
	void handle_write(const boost::system::error_code& error);
	boost::asio::ip::tcp::socket socket_;
	enum { max_length = 1024 };
	char data_[max_length];
};

class Server
{
public:
	Server(boost::asio::io_service& io_service, short port);
	~Server();

private:
	void start_accept();
	void handle_accept(session_ptr new_session, const boost::system::error_code& error);
	boost::asio::io_service& io_service_;
	boost::asio::ip::tcp::acceptor acceptor_;
};

#endif // ! _ECHOSERVER_H_
