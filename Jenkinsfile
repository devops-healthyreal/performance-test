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
                          docker exec -i $JMETER_CONTAINER jmeter -n \
                            -t $JMETER_DIR/tests/performance/load_test.jmx \
                            -l $RESULTS_DIR/result-$(date +%H%M).jtl \
                            -Jbackend_prometheus.port=9270 \
                            -Jbackend_prometheus.metric_path=/metrics \
                            -Jbackend_prometheus.classname=io.jmeter.plugins.prometheus.Listener \
                            -e -o $RESULTS_DIR/report-$(date +%H%M)
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
