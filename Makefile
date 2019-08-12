init-project:
	mkdir src
	mkdir src/main
	mkdir src/main/java
	mkdir src/test
	mkdir src/test/java
	mkdir src/META-INF

setup:
	mkdir --parents build
	mkdir --parents build/classes
	mkdir --parents build/classes/test
	mkdir --parents build/jars
	mkdir --parents docs

clean:
	rm -rf lib
	rm -rf docs
	rm -rf build
	rm -rf target

test-deps:
	mkdir lib
	curl --location --insecure --url https://search.maven.org/remotecontent?filepath=junit/junit/4.12/junit-4.12.jar --output lib/junit-4.12.jar
	curl --location --insecure --url https://search.maven.org/remotecontent?filepath=org/hamcrest/hamcrest/2.1/hamcrest-2.1.jar --output lib/hamcrest-2.1.jar

compile: setup
	javac -classpath .:lib -sourcepath src/main/java -d build/classes src/main/java/hello/App.java

jar: compile
	jar -cmf src/META-INF/MANIFEST.MF build/jars/java_project_001.jar -C build/classes hello/App.class

run-classes: compile
	java -cp .:build/classes hello.App

run-jars: jar
	java -jar build/jars/java_project_001.jar

junit-compile: test-deps compile
	javac -classpath .:lib/junit-4.12.jar:lib/hamcrest-2.1.jar src/test/java/**/*Test.java

junit-test: junit-compile
	java -classpath .:lib/junit-4.12.jar:lib/hamcrest-2.1.jar org.junit.runner.JUnitCore TestHelloWorld

generate-java-keytool:
	# The keystore.conf should not be checked into Source Control unless encrypted
	# with GPG or some sort of vault tool like Ansible vault, Chef Encrypted Data Bags
	# or HashiCorp Vault.
	# 
	# @see https://docs.oracle.com/javase/tutorial/deployment/jar/signindex.html
	# @see https://introcs.cs.princeton.edu/java/85application/jar/sign.html
	#
	# More than likely you'll have Self-Signed keystore if you follow this route and won't be
	# verifiable or trusted if others verify your JAR.
	# You may want to look into these Documents for more information about using
	# signed certificates.
	#
	# @see https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html	
	# @see https://docs.oracle.com/javase/8/docs/technotes/tools/unix/jarsigner.html
	keytool -genkey -alias key-alias-name -keystore phil-keystore < keystore.conf

sign-jar:
	jarsigner -keystore phil-keystore -storepass fake-store-pass -keypass fake-key-pass build/jars/java_project_001.jar key-alias-name

docs:
	javadoc -html5 -d docs -sourcepath src/main/java src/main/java/**/*.java
