AWS = require("aws-sdk")
_ = require("lodash")

config = require './config'

opts = 
  accessKeyId: config.aws.key
  secretAccessKey: config.aws.secret
  bucket: config.aws.bucket
  # access:'public-read'


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

s3_client.createBucket (err, something)->
  console.log err if err
  console.log something
  console.log 'Bucket created'

  s3_client.putObject data, (err, d) ->
    console.log err if err 
    console.log d
    console.log 'obj uploaded'


s3_client.getBucketWebsite {Bucket: config.aws.bucket}, (err) ->
  if err and err.name is "NoSuchWebsiteConfiguration"
    
    #opts.enableWeb can be the params for WebsiteRedirectLocation.
    #Otherwise, just set the index.html as default suffix
    console.log "Enabling website configuration on " + opts.Bucket + "..."
    webOptions = (if _.isObject(opts.enableWeb) then opts.enableWeb else IndexDocument:
      Suffix: "index.html"
    )
    # return callback()  if opts.dryRun
    s3_client.putBucketWebsite
      Bucket: opts.bucket
      WebsiteConfiguration: webOptions
    , (e)-> console.log e
  else
    console.log err




