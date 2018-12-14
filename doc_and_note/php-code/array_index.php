<?php
	$states = array(0 => "ohio", 1 => "pennsylvania", 2 => "NEW YORK");
	echo "<p>".$states[0]."</p>";

	$states = array("OH" => "ohio", "PA" => "pennsylvania", "NY" => "NEW YORK");
	echo "<p>".$states["OH"]."</p>";

	$states = array(
			"Ohid" => array("population" => "11,353,140", "capital" => "Columbus"),
			"Nebraska" => array("population" => "1,711,263", "capital" => "Omaha")
				);
	echo "<p> er wei :".$states["Ohid"]["population"]."</p>";

	echo "<p>------ create array ----------</p>";
	echo "<p>------ 1. abnormal type ------------- </p>";

	$state[0] = "Delaward";
	echo "<p> xxxxx-----".$state[0]."</p>";
	$state[1] = "pennsylvania";
	$state[2] = "new jersey";
	echo "<p> attend :".$state[1]." .. ".$state[2]."</p>";
	$state[] = "4frorrr";
	$state[] = " 5xxxxxx";
	for ($i=0; $i < 5 ; $i++) { 
		echo "<p> i = ".$i.",value = ".$state[$i]."</p>";
	}
	echo "<p>--------type two create array() ----------------</p>";
	$languages = array("spain" => "spanish", "Ireland" => "Gaelic", "United States" => "English");
	foreach ($languages as $key => $value) {
		echo "<p> key = ".$key.",value = ".$value."</p>";
	}

	echo "<p> -------use list()--------</p>";

	//打开 users.txt 文件
	$users = fopen("users.txt", "r");

	//若未到达EOF，则获取下一行
	while ($line = fgets($users, 4096)) {
		//用explode()分离数据片段
		list($name, $occupation, $color) = explode("|", $line);
		//格式化数据并输出
		printf("Name: %s <br />", $name);
		printf("occupation: %s <br />", $occupation);
		printf("Favorite color: %s <br />", $color);
	}
	fclose($users);

	echo "<p> --------------------</p>";
	$idle = range(1,6);
	// foreach ($idle as $key => $value) {
	// 	echo "<p> key =".$key.",value=".$value."</p>";
	// }
	foreach ($idle as $value) {
		echo "<p> ---".$value."</p>";
	}

	echo "<p>-------use step--------</p>";
	$even = range(0,20,2);
	foreach ($even as $key => $value) {
		echo "<p> key=".$key.",value=".$value."</p>";
	}

	echo "<p> ------test array----------</p>";
	echo "\$idle is array, ".is_array($idle)."</p>";

	echo "<p> --------print array------</p>";
	print_r($even);

	echo "<p>----add and del array ------</p>";
	echo "<p>----add head and tail-------</p>";
	array_unshift($idle, 0);
	array_push($idle, 7);

	print_r($idle);

	echo "<p>----del head and tail--------</p>";
	array_shift($even);
	array_pop($even);
	print_r($even);

	echo "<p>----------in_array()------------</p>";
	$state = "Ohid";
	$states = array("California", "Hawaii", "Ohid", "New York");
	if (in_array($state, $states)) 
		echo "Not to worry, $state is smoke-free!";
?>