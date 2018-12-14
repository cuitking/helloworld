<?php
	$links = array("www.apress.com", "www.php.net", "www.apache.org");
	echo "<b> online resource </b>:<br />";
	foreach ($links as $link) {
		echo "<a href=\"http://$link\">$link</a><br />";
	}
	echo "<p>---------key and value  array ---------------</p>";
	$linkbs = array('the appache web server' => "www.apache.org", 
					"Apress" => "www.apress.com",
					"The php scripting Language " => "www.php.net");
	foreach ($linkbs as $title => $link) {
		echo "<a href=\"http://$link\">$title</a><br />";
	}

	echo "<p>----------use function-------------</p>";

	$value = pow(5, 3);
	echo "<p> 5 de 3 ci fang :".$value."</p>";

	function generateFooter()
	{
		echo "Copyright 2010 W. Jason Gilmore";
	}
	generateFooter();
	
	echo "<p> </p>";

	function calcSalesTax($price, $tax)
	{
		$total = $price + ($price * $tax);
		echo "Total cost: $total";
	}
	$pricetag = 15.00;
	$salestax = .075;
	calcSalesTax($pricetag, $salestax);

	echo "<p>----------按引用传递----------------</p>";

	$cost = 20.99;
	$tax = 0.0575;

	function calculateCost(&$cost, $tax)
	{
		$cost = $cost + ($cost * $tax);
		$tax += 4;
	}
	calculateCost($cost, $tax);
	printf("Tax is %01.2f%% ", $tax*100);
	printf("Cost is $%01.2f", $cost);

	echo "<p> ----默认参数----------</p>";

	function calcSalesTax_a($price, $tax=.0675)
	{
		$total = $price + ($price * $tax);
		echo "Total cost: $total";
	}
	$price = 15.47;
	calcSalesTax_a($price);


	function calcSalesTax_b($price, $tax=0)
	{
		$total = $price + ($price * $tax);
		echo "Total cost: $total";
	}

	calcSalesTax_b(42);

	echo "<p> ------</p>";

	function calculate($price, $price2="", $price3=0)
	{
		echo $price + intval($price2) + $price3;
	}

	calculate(10, "", 3);

	echo "<p> ------测试返回值--------</p>";

	function calcSalesTax_re($price, $tax=.0675)
	{
		$total = $price + ($price * $tax);
		return $total;
	}

	function calcSalesTax_rea($price, $tax=.0675)
	{
		return $price + ($price * $tax);
	}
    
    $price = 6.99;
    $total_a = calcSalesTax_re($price);
    $total_b = calcSalesTax_rea($price);
    echo "------total_a ".$total_a.", total_b = ".$total_b;
    
    echo "<p> -------多个返回值------</p>";

    $colors = array("red", "blue", "green");
    list($red, $blue, $green) = $colors;

    function retrieveUserProfile() 
    {
    	$user[] = "Jason Gilmore";
    	$user[] = "jason@example.com";
    	$user[] = "English";
    	return $user;
    }
    list($name, $email, $language) = retrieveUserProfile();
    echo "Name: $name, email: $email, language: $language";

    echo "<p> -----digui hanshu ------</p>";

    //还贷计算器
    function amortizationTable($pNum, $periodPayment, $balance, $monthlyInterest)
    {
    	//计算支付利息
    	$paymentInterest = round($balance * $monthlyInterest, 2);

    	//计算还款额
    	$paymentPrincipal = round($periodPayment - $paymentInterest, 2);

    	//用余额减去还款额
    	$newBalance = round($balance - $paymentPrincipal, 2);

    	//如果余额 < 每月还款 ,设置为0
    	if ($newBalance < $paymentPrincipal) {
    		$newBalance = 0;
    	}

    	printf("<tr><td>%d</td>", $pNum);
    	printf("<td>$%s</td>", number_format($newBalance, 2));
    	printf("<td>$%s</td>", number_format($periodPayment, 2));
    	printf("<td>$%s</td>", number_format($paymentPrincipal,2));
    	printf("<td>$%s</td></tr>", number_format($paymentInterest,2));

    	if ($newBalance > 0) {
    		$pNum++;
    		amortizationTable($pNum, $periodPayment, $newBalance, $monthlyInterest);
    	} else {
    		return 0;
    	}
    }

    //贷款余额
    $balance = 10000.00;

    //贷款利率
    $interestRate = .0575;

    //没月利率
    $monthlyInterest = $interestRate / 12;

    //贷款期限,单位为年
    $termLength = 5;

    // 每年支付次数
    $paymentsPerYear = 12;

    // 付款迭代
    $paymentNumber = 1;

    //确定总支付次数
    $totalPayments = $termLength * $paymentsPerYear;

    //确定分期付款的利息部分
    $intCalc = 1 + $interestRate / $paymentsPerYear;

    //确定定期支付
    $periodicPayment = $balance * pow($intCalc, $totalPayments) * ($intCalc - 1) / (pow($intCalc, $totalPayments) - 1);

    //每月还款额限制到小数点后两位
    $periodicPayment = round($periodicPayment, 2);

    //创建表
    echo "<table width='50%' align='center' border='1'>";

    echo "<tr>
    		<th> Payment Number </th><th>Balance</th>
    		<th>Payment</th><th>Principal</th><th>Interest</th>
    		</tr>";

    //创建递归函数
    amortizationTable($paymentNumber, $periodicPayment, $balance, $monthlyInterest);

    echo "</table>";
?>