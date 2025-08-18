# サービスアカウントに必要なロールを付与
gcloud projects add-iam-policy-binding prd-iac-neko \
  --member="serviceAccount:terraform-sa@prd-iac-neko.iam.gserviceaccount.com" \
  --role="roles/editor"

# または、より具体的な権限を付与
gcloud projects add-iam-policy-binding prd-iac-neko \
  --member="serviceAccount:terraform-sa@prd-iac-neko.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding prd-iac-neko \
  --member="serviceAccount:terraform-sa@prd-iac-neko.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding prd-iac-neko \
  --member="serviceAccount:terraform-sa@prd-iac-neko.iam.gserviceaccount.com" \
  --role="roles/certificatemanager.editor"

gcloud projects add-iam-policy-binding prd-iac-neko \
  --member="serviceAccount:terraform-sa@prd-iac-neko.iam.gserviceaccount.com" \
  --role="roles/dns.admin"