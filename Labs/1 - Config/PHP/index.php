<html>
<head>
	<title>
		Accessing App Settings from PHP
	</title>

	<style>
		li { font-size: 24px;}
		label { color: dodgerblue; }
	</style>

</head>
<body>

<h1>Hello from <?php echo getenv("CloudProvider"); ?></h1>

<ul>
<li><label>Location:</label> <?php echo getenv("APPSETTING_Location"); ?></li> 
<li><label>AppName:</label> <?php echo getenv("APPSETTING_AppName"); ?></li>
</ul>

<h3>Happy Clouding!</h3>

</body>
</html>