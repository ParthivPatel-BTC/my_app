require 'aws-sdk-s3'
Aws.config.update({
                    region: 'us-east-1',
                    credentials: Aws::Credentials.new(ENV['ACCESS_KEY'], ENV['SECRET_KEY'])
                  })
S3_CONCIERGEREQUEST_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])
