
export DB_PASS=$(aws ssm get-parameter --name="catgram-db-pass" --with-decryption --query="Parameter.Value" --output=text)
export PAPERCLIP_SECRET=$(aws ssm get-parameter --name="catgram-paperclip-secret" --with-decryption --query="Parameter.Value" --output=text)
export SECRET_KEY_BASE=$(aws ssm get-parameter --name="catgram-secret-key-base" --with-decryption --query="Parameter.Value" --output=text)
export OPT_SECRET=$(aws ssm get-parameter --name="catgram-opt-secret" --with-decryption --query="Parameter.Value" --output=text)
export VAPID_PRIVATE_KEY=$(aws ssm get-parameter --name="catgram-vapid-private-key" --with-decryption --query="Parameter.Value" --output=text)
export VAPID_PUBLIC_KEY=$(aws ssm get-parameter --name="catgram-vapid-public-key" --with-decryption --query="Parameter.Value" --output=text)
export SMTP_PASSWORD=$(aws ssm get-parameter --name="catgram-smtp-password" --with-decryption --query="Parameter.Value" --output=text)
