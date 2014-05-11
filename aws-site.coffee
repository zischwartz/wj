AWS = require("aws-sdk")
_ = require("lodash")

config = require './config'

opts = 
  accessKeyId: config.aws.key
  secretAccessKey: config.aws.secret
  bucket: config.aws.bucket

dns = require './aws-domain'

AWS.config.update opts

s3_client = new AWS.S3
  params:
    Bucket: config.aws.bucket

data = {Key: 'index.html', Body: 'boo!'}

policy = {
  "Version": "2008-10-17",
  "Statement": [{
    "Sid": "AllowPublicRead",
    "Effect": "Allow",
    "Principal": { "AWS": "*" },
    "Action": ["s3:GetObject"],
    "Resource": ["arn:aws:s3:::#{config.aws.bucket}/*" ]
  }]
}

s3_client.putBucketPolicy  {Policy : JSON.stringify policy}, (err, d)->
  console.log d
  console.log err if err

s3_client.createBucket (err)->
  console.log err if err
  console.log 'Bucket created'

  # s3_client.putObject data, (err, d) ->
  #   console.log err if err 
  #   console.log 'obj uploaded'

s3_client.getBucketWebsite {Bucket: config.aws.bucket}, (err) ->
    console.log "Enabling website configuration on " + opts.bucket + "..."
    webOptions = {IndexDocument:Suffix: "index.html"}
    s3_client.putBucketWebsite
      Bucket: opts.bucket
      WebsiteConfiguration: webOptions
    , (e,d)-> console.log 'x'; console.log  e, d, '---', s3_client
  # else
    # console.log 'getBucketWebsite err:'
    # console.log err

# works!, not concurrently though?
# domain
# route53 = new AWS.Route53()
# dns_options =
#   route53: route53
#   domain: 'coool.net'
# dns.create dns_options, (e, z)-> console.log e; console.log z



