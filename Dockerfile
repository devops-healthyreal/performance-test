FROM justb4/jmeter:latest

# JMeter 확장 폴더가 없을 수 있으므로 먼저 생성
RUN mkdir -p /opt/apache-jmeter/lib/ext

# Prometheus Backend Listener 플러그인 설치
RUN wget -q -O /opt/apache-jmeter/lib/ext/jmeter-prometheus-plugin.jar \
    https://github.com/johrstrom/jmeter-prometheus-plugin/releases/download/0.6.0/jmeter-prometheus-plugin-0.6.0.jar

# JMeter 서버 모드로 항상 실행되게 설정
CMD ["jmeter-server", "-Jbackend_prometheus.port=9270", "-Jbackend_prometheus.metric_path=/metrics", "-Dserver.rmi.localport=50000", "-Dserver_port=1099"]