#include "stdafx.h"

program_options::program_options():desc("Allowed options")
{
	desc.add_options()
		("help","produce help message")
		("compression", po::value<int>(), "set compression level")
		;
}


void program_options::program_set(int argc, char** argv)
{
	try
	{
		po::store(po::parse_command_line(argc, argv, desc), vm);
		po::notify(vm);
	}
	catch (...)
	{
		std::cout << "option not found!!" << "\n";
	}

	if (vm.count("help")) {
		std::cout << desc << "\n";
	}

	/*if (vm.count("compression")) {
		std::cout << "Compression level was set to "
			<< vm["compression"].as<int>() << ".\n";
	}
	else {
		std::cout << "Compression level was not set.\n";
	}*/

}