#include "postTask.h"


void CpostTask::foo()
{
	std::cout << " hello asio " << std::endl;
}
void CpostTask::post()
{
	ios.post(boost::bind(&CpostTask::foo, this));
}
void CpostTask::run()
{
	ios.run();
}


CpostTaskIN::CpostTaskIN()
{
}

CpostTaskIN::~CpostTaskIN()
{
}
void CpostTaskIN::handler_foo()
{
	std::cout << "misson complete !!!!!!!!!!!" << std::endl;
}
void CpostTaskIN::foo(handler_t handler)
{
	std::cout << "begin excute asio ,hello aiso !!!!" << std::endl;

	handler(this);
}

void CpostTaskIN::post()
{
	ios.post(boost::bind(&CpostTaskIN::foo, this, &CpostTaskIN::handler_foo));
}

void CpostTaskIN::run()
{
	ios.run();
}


PostTaskThreads::PostTaskThreads()
{

}

PostTaskThreads::~PostTaskThreads()
{
	
}

void PostTaskThreads::foo()
{
	std::cout << "hello asio !!! thread ID : " << boost::this_thread::get_id() << std::endl;
}

void PostTaskThreads::postTask(int num)
{
	for (int i = 0; i < num; ++i)
	{
		ios.post(boost::bind(&PostTaskThreads::foo,this));
	}
}

void PostTaskThreads::addToThreads(int threadsNum)
{
	for (int i = 0; i < threadsNum; ++i)
	{
		threads.create_thread(boost::bind(&boost::asio::io_service::run, &ios));
	}
}

void PostTaskThreads::joinAll()
{
	threads.join_all();
}

TaskRun::TaskRun() :sumNum(0)
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
	while (!ios.stopped()) ///ÓëÊ¹ÓÃios.run() ÓÐÏàÍ¬µÄÐ§¹û
	{
		ios.run_one();
	}
}


/*-------------------------------------------------------*/
TaskFileSystem::TaskFileSystem(const char* cPath) :pa(cPath), di(pa, ec)
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

/*---------------------------*/
TaskWithWork::TaskWithWork() :works(new boost::asio::io_service::work(ios))
{
}
TaskWithWork::~TaskWithWork()
{
	if (works != NULL)
	{
		delete works;
		works = NULL;
	}
}
void TaskWithWork::foo()
{
	std::cout << " hello foo !!!!!!!!!!" << std::endl;
}

void TaskWithWork::post()
{
	ios.post(boost::bind(&TaskWithWork::foo, this));
	boost::thread thd(boost::bind(&TaskWithWork::thd_fun, this));
}
void TaskWithWork::thd_fun()
{
	std::getchar();
	if (works != NULL)
	{
		delete works;
		works = NULL;
	}
}
void TaskWithWork::run()
{
	ios.run(ec);
}

/*--------------------------------------------*/
BaseNet::BaseNet(int posts) :endpoint(boost::asio::ip::tcp::v4(), posts), acceptor(ios, endpoint)
{
}
BaseNet::~BaseNet()
{
	for (std::vector<boost::asio::ip::tcp::socket*>::iterator it = socks.begin(); it != socks.end(); it++)
	{
		boost::asio::ip::tcp::socket* sockit = (*it);
		if (sockit != NULL)
		{
			delete sockit;
			sockit = NULL;
		}
	}
	socks.clear();
}

void BaseNet::Async_Session(boost::asio::ip::tcp::socket* iosocket)
{
	std::cout << " connect successs !!!!!" << std::endl;

	char data[MAXLENBUF] = {};

	for (;;)
	{
		boost::system::error_code error_code;
		size_t length = iosocket->read_some(boost::asio::buffer(data), error_code);
		if (error_code == boost::asio::error::eof)
			break;
		else if (error_code)
		{
			std::cout << " there is something wrong happened!!!!!!!" << error_code.message() << std::endl;
			break;
		}
		std::cout << "received  size :" << length << " contents: " << data << std::endl;
		iosocket->write_some(boost::asio::buffer(data, length), error_code);
		if (error_code)
		{
			std::cout << " write wrong  happened !!!!!!!!!!!" << error_code.message() << std::endl;
		}
	}
	delete iosocket;
	iosocket = NULL;
	std::cout << " connection over!!!" << std::endl;
}

void BaseNet::WaitConnect()
{
	for (;;)
	{
		boost::asio::ip::tcp::socket* sockde = new boost::asio::ip::tcp::socket(ios);
		socks.push_back(sockde);
		acceptor.accept(*sockde);

		boost::thread(boost::bind(&BaseNet::Async_Session, this, sockde)).detach();

	}
}
/*-------------asio 7 coroutine----------------*/
Stackless::Stackless()
{

}

Stackless::~Stackless()
{
	
}

int Stackless::foo(boost::asio::coroutine& ct)
{
	std::cout << " before reenter " << std::endl;

	reenter(ct)
	{
		std::cout << " before yield1 " << std::endl;
		yield std::cout << " yield1 " << std::endl;
		std::cout << "before yield2 " << std::endl;
		yield return 1;
	}

	std::cout << "after reenter" << std::endl;
	return 2;

}

void Stackless::check()
{
	while (!ct.is_complete())
	{
		int ret = foo(ct);
		std::cout << " return : " << ret << std::endl;
	}
}