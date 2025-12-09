FROM justb4/jmeter:latest

# JMeter 확장 플러그인 폴더 생성
RUN mkdir -p /opt/apache-jmeter-5.5/lib/ext

# Prometheus Backend Listener 플러그인 설치
RUN wget -q -O /opt/apache-jmeter-5.5/lib/ext/jmeter-prometheus-plugin.jar \
    https://github.com/johrstrom/jmeter-prometheus-plugin/releases/download/0.6.0/jmeter-prometheus-plugin-0.6.0.jar
    
RUN wget -q -O /opt/apache-jmeter-5.5/lib/metrics-core-2.2.0.jar \
    https://repo1.maven.org/maven2/com/yammer/metrics/metrics-core/2.2.0/metrics-core-2.2.0.jar

# JMeter 서버 모드로 항상 실행되게 설정
CMD ["-s", "-Jbackend_prometheus.port=9270", "-Jbackend_prometheus.metric_path=/metrics", "-Dserver.rmi.localport=5100", "-Dserver_port=5101", "-Djava.rmi.server.hostname=0.0.0.0", "-Dserver.rmi.ssl.disable=true"]
