pipeline {
    agent any

    environment {
        JMETER_SERVER = "ubuntu@3.39.158.19"
        JMETER_DIR = "/home/ubuntu/performance-test"
        JMETER_CONTAINER = "jmeter-prometheus"
        RESULTS_DIR = "/home/ubuntu/results"
    }

    stages {
        stage('Checkout Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/devops-healthyreal/performance-test.git'
            }
        }

        stage('Deploy Test Plan to JMeter Server') {
            steps {
                sshagent(['admin']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no $JMETER_SERVER '
                          mkdir -p $JMETER_DIR/tests/performance $RESULTS_DIR
                        '
                        scp -o StrictHostKeyChecking=no tests/performance/load_test.jmx \
                            $JMETER_SERVER:$JMETER_DIR/tests/performance/
                    """
                }
            }
        }

        stage('Run JMeter Test') {
            steps {
                sshagent(['admin']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no $JMETER_SERVER '
                        echo "🧹 Checking if /tmp/results/report is non-empty..."
                        docker exec -i $JMETER_CONTAINER sh -c "
                            if [ -d /tmp/results/report ] && [ \\"\\\$(ls -A /tmp/results/report)\\" ]; then
                            echo '⚠️ /tmp/results/report not empty — cleaning up...'
                            rm -rf /tmp/results/report/*
                            rm -f /tmp/results/*
                            else
                            echo '✅ /tmp/results/report is already empty or does not exist.'
                            fi
                        "

                        echo "🚀 Starting JMeter test..."
                        docker exec -i $JMETER_CONTAINER jmeter -n \
                            -t /tmp/performance-test/tests/performance/load_test.jmx \
                            -l /tmp/results/result.jtl \
                            -Jbackend_prometheus.port=9270 \
                            -Jbackend_prometheus.metric_path=/metrics \
                            -Jbackend_prometheus.address=0.0.0.0 \
                            -Jbackend_prometheus.classname=io.jmeter.plugins.prometheus.Listener \
                            -Jserver.rmi.localhostname=0.0.0.0 \
                            -Djava.net.preferIPv4Stack=true \
                            -e -o /tmp/results/report
                        '
                    """
                }
            }
        }

        stage('Post Test Summary') {
            steps {
                echo "✅ JMeter Load Test completed. Check Grafana for live metrics."
            }
        }
    }

    post {
        failure {
            echo "❌ JMeter test failed. Please check Jenkins logs."
        }
    }
}
