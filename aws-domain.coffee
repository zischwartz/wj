AWS = require("aws-sdk")
_ = require("lodash")

config = require './config'

async = require("async")
# _ = require("underscore")
uuid = require("uuid")
# CALLER_REFERENCE = "caisson"

# Based on https://github.com/christophercliff/caisson
# -------------------------------------------------------------

HOSTED_ZONE_ID_RE = /^\/hostedzone\//
S3_HOSTED_ZONE_IDS =
  # Listed here: http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region
  "us-east-1": "Z3AQBSTGFYJSTF"
  "us-west-1": "Z2F56UZL2M1ACD"
  "us-west-2": "Z3BJ6K6RIION7M"
  "eu-west-1": "Z1BKCTXD74EZPE"
  "ap-southeast-1": "Z3O0J2DXBE1FTB"
  "ap-southeast-2": "Z1WCIGYICN2BYD"
  "ap-northeast-1": "Z2M4EHUR26P7ZW"
  "sa-east-1": "Z7KQH4QJS55SO"

createHostedZoneParams = (domain) ->
  Name: domain
  CallerReference: uuid.v1()

changeResourceRecordSetsParams = (domain, hostedZoneId, region) ->
  HostedZoneId: hostedZoneId
  ChangeBatch:
    Changes: [
      {
        Action: "CREATE"
        ResourceRecordSet:
          Name: domain + "."
          Type: "A"
          AliasTarget:
            HostedZoneId: S3_HOSTED_ZONE_IDS[region]
            DNSName: "s3-website-" + region + ".amazonaws.com."
            EvaluateTargetHealth: false
      }
      {
        Action: "CREATE"
        ResourceRecordSet:
          Name: "www." + domain + "."
          Type: "CNAME"
          TTL: 300
          ResourceRecords: [Value: "www." + domain + ".s3-website-" + region + ".amazonaws.com"]
      }
    ]

parseHostedZoneId = (res) ->
  res.HostedZone.Id.replace HOSTED_ZONE_ID_RE, ""

create = (options, callback) ->
  route53 = options.route53
  domain = options.domain
  region = options.region
  route53.listHostedZones (err, res) ->
    hostedZone = undefined
    hostedZoneId = undefined
    return callback(new Error(err))  if err
    hostedZone = _.findWhere(res.HostedZones,
      Name: domain + "."
    )
    if hostedZone
      return route53.getHostedZone(
        Id: hostedZone.Id
      , callback)
    async.waterfall [
      async.apply(route53.createHostedZone.bind(route53), createHostedZoneParams(domain))
      (res, c) ->
        hostedZoneId = parseHostedZoneId(res)
        route53.changeResourceRecordSets changeResourceRecordSetsParams(domain, parseHostedZoneId(res), region), c
    ], (err, res) ->
      return callback(new Error(err))  if err
      route53.getHostedZone
        Id: hostedZoneId
      , callback

    return

  return

exports.createHostedZoneParams = createHostedZoneParams
exports.changeResourceRecordSetsParams = changeResourceRecordSetsParams
exports.create = create