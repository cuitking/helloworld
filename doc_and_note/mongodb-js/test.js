var dbIP = '172.27.1.5:27017'
var GameConfigDBName = dbIP + '/GameConfig';
var GameConfigDB = connect(GameConfigDBName);
var GameConfigAdminDB = GameConfigDB.getSiblingDB('admin');
GameConfigAdminDB.auth('root','qzmp!@#456');

var info = GameConfigAdminDB.adminCommand("listDatabases");
var info2 = GameConfigAdminDB.getCollectionNames();
//printjson(info.databases);
/* for (var key in info.databases)
{
	print(info.databases[key].name);
} */
//printjsononeline(info);
print(info2);
printjson(info2);