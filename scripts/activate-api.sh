# プロジェクト設定確認
gcloud config get-value project

# 必要なAPIを一括有効化
gcloud services enable \
  run.googleapis.com \
  compute.googleapis.com \
  certificatemanager.googleapis.com \
  dns.googleapis.com \
  container.googleapis.com \
  cloudbuild.googleapis.com