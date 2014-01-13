default['vendorname'] = "Oracle"
default['maintainer'] = "Oracle"
default['java']['name'] = "oracle"

default['java']['provides'] = [
	"java-runtime",
	"java7-runtime",
	"java6-runtime",
	"java5-runtime",
	"java2-runtime",
	"java6-runtime-headless",
	"java5-runtime-headless",
	"java2-runtime-headless",
	"java-runtime-headless"
]
default['java']['provides_jdk'] = [
	"java7-jdk",
	"java6-sdk",
	"java5-sdk",
	"java2-sdk",
	"java-sdk",
	"java-compiler"
]

default['java']['edition']['jdk7']['name'] = "Oracle JDK7"
default['java']['edition']['jdk7']['version'] = "1.7.0-45"
default['java']['edition']['jdk7']['jdk'] = true
default['java']['edition']['jdk7']['archs']['x86_64'] = "http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jdk-7u45-linux-x64.tar.gz"

default['java']['edition']['jre7']['name'] = "Oracle JRE7"
default['java']['edition']['jre7']['version'] = "1.7.0-45"
default['java']['edition']['jre7']['jdk'] = false
default['java']['edition']['jre7']['archs']['x86_64'] = "http://download.oracle.com/otn-pub/java/jdk/7u45-b18/server-jre-7u45-linux-x64.tar.gz"
