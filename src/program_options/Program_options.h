#ifndef _PROGRAM_OPTIONS_H_
#define _PROGRAM_OPTIONS_H_

#include <boost/program_options.hpp>

namespace po = boost::program_options;

class program_options
{
public:
	program_options();
	void program_set(int argc, char** argv);

private:
	po::variables_map vm;
	po::options_description desc;
};

#endif
