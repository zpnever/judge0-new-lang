@edgar_langs ||= []
@edgar_langs += 
[
	{
		"name": "Java (OpenJDK 21.0.2)",
		"is_archived": false,
		"source_file": "Main.java",
		"compile_cmd": "/usr/lib/jvm/jdk-21.0.2/bin/javac -Xlint:none %s Main.java",
		"run_cmd": "/usr/lib/jvm/jdk-21.0.2/bin/java -cp /usr/lib/jvm/edgar-libs/edgar.jar:. Main"
	}
]
