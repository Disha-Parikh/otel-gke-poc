pipeline {
  agent any
  parameters {
    choice(name: 'ENV', choices: ['dev', 'staging'], description: 'Target environment')
  }
  stages {
    stage('Terraform Apply') {
      steps {
        dir("terraform/envs/${params.ENV}") {
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Configure kubectl') {
      steps {
        sh "gcloud container clusters get-credentials otel-${params.ENV} --region us-central1"
      }
    }

    stage('Install Observability') {
      steps {
        sh '''
        helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
        helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
        helm upgrade --install otel-agent open-telemetry/opentelemetry-collector -n observability --create-namespace -f helm/otel-agent-values.yaml
        helm upgrade --install otel-gateway open-telemetry/opentelemetry-collector -n observability -f helm/otel-gateway-values.yaml
        helm upgrade --install jaeger jaegertracing/jaeger -n observability --set query.enabled=true --set collector.enabled=true --set storage.type=memory
        kubectl apply -f helm/instrumentation.yaml
        '''
      }
    }

    stage('Deploy Apps') {
      steps {
        sh '''
        kubectl apply -f k8s/backend.yaml
        kubectl apply -f k8s/frontend.yaml
        '''
      }
    }
  }
}

