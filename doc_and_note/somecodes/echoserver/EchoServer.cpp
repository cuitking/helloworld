#include "EchoServer.h"


session::session(boost::asio::io_service& io_service):socket_(io_service)
{
	
}

session::~session()
{
	std::cout << " session destroy!!!!!!" << std::endl;
}

session_ptr session::get_new_session(boost::asio::io_service& io_service)
{
	return session_ptr(new session(io_service));
}

boost::asio::ip::tcp::socket& session::socket()
{
	return socket_;
}

void session::handle_read(const boost::system::error_code& error, size_t bytes_transferred)
{
	if (!error)
	{
		boost::asio::async_write(socket_, 
			boost::asio::buffer(data_,bytes_transferred),
			boost::bind(&session::handle_write, shared_from_this(),
			boost::asio::placeholders::error));
	}
}

void session::handle_write(const boost::system::error_code& error)
{
	if (!error)
	{
		socket_.async_read_some(boost::asio::buffer(data_, max_length),
			boost::bind(&session::handle_read, shared_from_this(),
				boost::asio::placeholders::error,
				boost::asio::placeholders::bytes_transferred));
	}
}

void session::start()
{
	socket_.async_read_some(boost::asio::buffer(data_, max_length),
		boost::bind(&session::handle_read, shared_from_this(),
			boost::asio::placeholders::error,
			boost::asio::placeholders::bytes_transferred));
}

/*----------------------------------------------------------*/

Server::Server(boost::asio::io_service& io_service, short port)
	:io_service_(io_service),
	acceptor_(io_service, boost::asio::ip::tcp::endpoint(boost::asio::ip::tcp::v4(), port))
{
	start_accept();
}

Server::~Server()
{
}

void Server::start_accept()
{
	session_ptr new_session = session::get_new_session(io_service_);
	acceptor_.async_accept(new_session->socket(),
		boost::bind(&Server::handle_accept, this, new_session,
			boost::asio::placeholders::error));
}

void Server::handle_accept(session_ptr new_session, const boost::system::error_code& error)
{
	if (!error)
	{
		new_session->start();
	}
	start_accept();
}