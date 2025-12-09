pipeline {
    agent any

    environment {
        REMOTE_HOST = "3.39.158.19"
        REMOTE_USER = "ubuntu"
        TEST_DIR = "/home/ubuntu/test"
        RESULT_DIR = "/home/ubuntu/results"
        JMETER_FILE = "./tests/performance/load_test.jmx"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "📥 GitHub 저장소에서 소스 코드 가져오는 중..."
                checkout scm
            }
        }

        stage('Deploy JMeter Test File') {
            steps {
                echo "📤 JMeter 테스트 파일을 원격 서버로 전송 중..."
                sshagent (credentials: ['admin']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} 'mkdir -p ${TEST_DIR} ${RESULT_DIR}'
                        scp -o StrictHostKeyChecking=no ${JMETER_FILE} ${REMOTE_USER}@${REMOTE_HOST}:${TEST_DIR}/load_test.jmx
                    """
                }
            }
        }

        stage('Run JMeter Test') {
            steps {
                echo "🚀 원격 서버에서 JMeter 테스트 실행 중..."
                sshagent (credentials: ['admin']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} '
                            jmeter -n \
                              -t ${TEST_DIR}/load_test.jmx \
                              -l ${RESULT_DIR}/result.jtl \
                              -Jbackend_prometheus.port=9270 \
                              -Jbackend_prometheus.metric_path=/metrics \
                              -Jbackend_prometheus.classname=io.jmeter.plugins.prometheus.Listener \
                              -e -o ${RESULT_DIR}/report
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ JMeter 테스트 완료 — 결과 파일은 /home/ubuntu/results/ 에 저장됨"
        }
        failure {
            echo "❌ 빌드 실패 — 로그를 확인하세요."
        }
    }
}
