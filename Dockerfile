# Base Image 
FROM tomcat:7
# Configuration of Application Environment
RUN set -ex \
	&& rm -rf /usr/local/tomcat/webapps/* \
	&& chmod a+x /usr/local/tomcat/bin/*.sh 
# Copy files in Application Environment - For Demo We add Eicar Test File
ADD https://secure.eicar.org/eicar.com.txt /root/
# Create Malware in Build
RUN echo "X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*" > eicar.file
#CMD ["chmod +x eicar.file", "./eicar.file"]
#Add Application Files .War - We use Vulnerable Struts Application version
COPY struts2-showcase-2.3.12.war /usr/local/tomcat/webapps/ROOT.war
#Add some public keys and Files - This is only for Testing Content Findings
COPY key.pem /usr/local/tomcat/webapps/key.pem
COPY ImportantFile.txt /usr/local/tomcat/webapps/ImportantFile.txt

#Expose the Service
EXPOSE 8080

FROM debian:testing-slim  
MAINTAINER Kalvin Harris <harriskalvin585@gmail.com>  
  
ARG DEBIAN_FRONTEND=noninteractive  
  
COPY entrypoint.sh /usr/local/bin/  
  
WORKDIR /tmp  
  
RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/zzz-no-
recommends \  
&& apt-get update && apt-get install -y \  
git ca-certificates build-essential autoconf automake \  
libssl-dev libcurl4-openssl-dev libjansson-dev libgmp-dev zlib1g-dev \  
libcurl3 libjansson4 libssl1.1 \  
&& git clone https://github.com/JayDDee/cpuminer-opt \  
&& cd cpuminer-opt && autoreconf -f -i -v \  
&& sed -i 's|"-O3 |"-Ofast |' build-allarch.sh && ./build-allarch.sh \  
&& mv -t /usr/local/bin/ cpuminer-avx2 cpuminer-aes-avx cpuminer-aes-sse42
cpuminer-sse42 cpuminer-ssse3 cpuminer-sse2 \  
&& chmod +x /usr/local/bin/* \  
&& apt-get remove \--purge --auto-remove -y \  
git ca-certificates build-essential autoconf automake \  
libssl-dev libcurl4-openssl-dev libjansson-dev libgmp-dev zlib1g-dev \  
&& rm -rf /tmp/* /var/lib/apt/lists/* /etc/apt/apt.conf.d/zzz-no-recommends \  
&& apt-get clean -y  
  
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]  
