require 'aws-sdk-core'

Aws.config.update(
  region: ENV.fetch('AMAZON_REGION', 'us-east-1'),
  credentials: Aws::Credentials.new(ENV['AMAZON_ACCESS_KEY_ID'], ENV['AMAZON_SECRET_ACCESS_KEY'])
)

::ACTIVITY_ARCHIVE_BUCKET = Aws::S3::Bucket.new('activity-archive.transparentclassroom.com')
