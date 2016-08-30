#include <iostream>
#include <boost/asio.hpp>
#include <string>

int main(int argc, char* argv[])
{
	boost::asio::io_service io_service;

	boost::asio::ip::tcp::resolver resolver(io_service);
	boost::asio::ip::tcp::resolver::query query(boost::asio::ip::tcp::v4(), "127.0.0.1", "23323");
	boost::asio::ip::tcp::resolver::iterator iterator = resolver.resolve(query);

	boost::asio::ip::tcp::socket sock(io_service);
	boost::asio::connect(sock, iterator);

	for (;;)
	{
		std::string line;
		getline(std::cin, line);

		boost::asio::write(sock, boost::asio::buffer(line.c_str(), line.size() + 1));

		char reply[1024];

		boost::asio::read(sock, boost::asio::buffer(reply, line.size() + 1));

		std::cout << reply << std::endl;
	}
	return 0;
}