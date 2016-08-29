#include "postTask.h"

TaskRun::TaskRun():sumNum(0)
{

}
TaskRun::~TaskRun()
{

}

void TaskRun::foo()
{
	std::cout << " value of sumNum :" << sumNum++ << std::endl;
}
void TaskRun::addTask(int num)
{
	for (int i = 0; i < num; ++i)
	{
		ios.post(boost::bind(&TaskRun::foo, this));
	}
}

void TaskRun::run()
{

	//ios.run();
	while (!ios.stopped()) ///与使用ios.run() 有相同的效果
	{
		ios.run_one();
	}
}


/*-------------------------------------------------------*/
TaskFileSystem::TaskFileSystem(const char* cPath):pa(cPath),di(pa,ec)
{
}
TaskFileSystem::~TaskFileSystem()
{

}

void TaskFileSystem::async_dir(boost::asio::io_service& io, boost::filesystem::directory_iterator& di)
{
	if (di == boost::filesystem::directory_iterator())
	{
		return;
	}

	if (boost::filesystem::is_directory(di->path()))
	{
		boost::system::error_code ec;
		boost::filesystem::directory_iterator sub_di(di->path(), ec);

		if (!ec)
		{
			ios.post(boost::bind(&TaskFileSystem::async_dir, this, boost::ref(ios), sub_di));
		}
		else
		{
			//std::cout << " bian li chu cuo :" << di->path() << "error !!!!!" << ec.message() << std::endl;
		}
	}
	//std::cout << " c path: " << di->path() << std::endl;
	boost::system::error_code ec;
	++di;
	ios.post(boost::bind(&TaskFileSystem::async_dir, this, boost::ref(ios), di));
	
}

void TaskFileSystem::post()
{
	if (!ec)
	{
		ios.post(boost::bind(&TaskFileSystem::async_dir, this, boost::ref(ios), di));
	}
	else
	{
		//std::cout << " bianli mulu " << pa << "error !!!!" << ec.message() << std::endl;
	}
}

void TaskFileSystem::run()
{
	ios.run();
}
