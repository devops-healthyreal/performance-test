pipeline {
    agent any

    environment {
        REMOTE_HOST = "3.39.158.19"
        REMOTE_USER = "ubuntu"
        REPO_URL = "https://github.com/devops-healthyreal/performance-test.git"
        REPO_DIR = "/home/ubuntu/performance-test"      // 클론 받을 위치
        TEST_DIR = "${REPO_DIR}/tests/performance"
        RESULT_DIR = "/home/ubuntu/results"
    }

    stages {
        stage('Git Clone or Pull on Remote Server') {
            steps {
                echo "📥 원격 서버에서 GitHub 리포지토리 업데이트 중..."
                sshagent(credentials: ['admin']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} '
                            if [ ! -d "${REPO_DIR}/.git" ]; then
                                echo "🔹 리포지토리가 존재하지 않아 clone 진행 중..."
                                git clone ${REPO_URL}
                            else
                                echo "🔹 기존 리포지토리 업데이트 중..."
                                cd ${REPO_DIR}
                                git fetch --all
                                git reset --hard origin/main
                            fi
                        '
                    """
                }
            }
        }

        stage('Run JMeter Test') {
            steps {
                echo "🚀 원격 서버에서 JMeter 부하 테스트 실행 중..."
                sshagent(credentials: ['admin']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} '
                            mkdir -p ${RESULT_DIR}
                            cd ${TEST_DIR}
                            jmeter -n \\
                              -t ${TEST_DIR}/load_test.jmx \\
                              -l ${RESULT_DIR}/result.jtl \\
                              -Jbackend_prometheus.port=9270 \\
                              -Jbackend_prometheus.metric_path=/metrics \\
                              -Jbackend_prometheus.classname=io.jmeter.plugins.prometheus.Listener \\
                              -e -o ${RESULT_DIR}/report
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ JMeter 부하 테스트 완료! 결과 리포트: /home/ubuntu/results/report"
        }
        failure {
            echo "❌ 빌드 실패 — 로그를 확인하세요."
        }
    }
}
