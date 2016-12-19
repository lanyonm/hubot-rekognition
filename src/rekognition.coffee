# Description:
#   Give Hubot an image and it'll tell you what it sees in the image.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_S3_BUCKET - the S3 bucket you'd like to upload images to
#   HUBOT_AWS_ACCESS_KEY_ID - an AWS access key for S3 and Rekognition
#   HUBOT_AWS_SECRET_ACCESS_KEY - a matching AWS secret key for S3 and Rekognition
#   HUBOT_AWS_REGION - the AWS region you'd like to use. eg: 'us-west-2'
#
# Commands:
#   @hubot What do you see? <picture>
#
# Notes:
#   None
#
# Author:
#   Mike Lanyon

crypto      = require 'crypto'
knox        = require 'knox'
Rekognition = require 'aws-sdk/clients/rekognition'
request     = require 'request'

module.exports = (robot) ->
  s3_bucket = process.env.HUBOT_S3_BUCKET
  aws_access_key = process.env.HUBOT_AWS_ACCESS_KEY_ID
  aws_secret_key = process.env.HUBOT_AWS_SECRET_ACCESS_KEY
  aws_region = process.env.HUBOT_AWS_REGION

  robot.respond /What have you seen?/i, (msg) ->
    callRekog msg, 'father-and-son.jpg'

  robot.respond /What do you see?/i, (msg) ->
    robot.logger.debug "Trying to figure out what's in this image..."
    if /uploads.hipchat.com/.test(msg.message.text)
      imageUrl = msg.message.text.split('https://s3.amazonaws.com/uploads.hipchat.com/')[1]
      if !imageUrl
        msg.send 'Sorry - I can\'t seem to parse that image url. :('
      robot.logger.debug "uploading this to s3: https://s3.amazonaws.com/uploads.hipchat.com/#{imageUrl}"
      s3FetchAndUpload msg, "https://s3.amazonaws.com/uploads.hipchat.com/#{imageUrl}", imageUrl.split('.')[1]
    else
      msg.send 'Sorry - it doesn\'t look like you gave me an image to look at.'

  sendRobotResponse = (msg, title, image, link) ->
    msg.send "#{title}: #{image} - #{link}"

  # Pick a random filename
  s3UploadPath = (ext) ->
    "#{crypto.randomBytes(20).toString('hex')}.#{ext}"

  s3FetchAndUpload = (msg, url, ext) ->
    requestHeaders =
      encoding: null
    request url, requestHeaders, (err, res, body) ->
      robot.logger.debug "Uploading file: #{body.length} bytes, content-type[#{res.headers['content-type']}]"
      uploadToS3(msg, ext, body, body.length, res.headers['content-type'])

  callRekog = (msg, filename) ->
    rekogParams =
      Image:
        S3Object:
          Bucket: s3_bucket
          Name: filename
      MaxLabels: 15
      MinConfidence: 30.0

    rekog = new Rekognition({
      apiVersion: '2016-06-27',
      region: aws_region,
      accessKeyId: aws_access_key,
      secretAccessKey: aws_secret_key
    })
    rekog.detectLabels rekogParams, (err, data) ->
      if err
        msg.send "Something bad happened... Although I was able to receive the image, I'm blind to it..."
      else
        labelArray = []
        for label in data.Labels
          labelArray.push "#{label.Name} (#{label.Confidence.toFixed(1)}%)"
        msg.send "I think I see: #{labelArray.join(', ')}"

  # Upload image to S3
  uploadToS3 = (msg, ext, content, length, content_type) ->
    client = knox.createClient {
      key    : aws_access_key
      secret : aws_secret_key,
      bucket : s3_bucket,
      region : aws_region
    }

    headers = {
      'Content-Length' : length,
      'Content-Type'   : content_type,
      'x-amz-acl'      : 'public-read',
      'encoding'       : null
    }

    filename = s3UploadPath(ext)

    req = client.put(filename, headers)
    req.on 'response', (res) ->
      if (200 == res.statusCode)
        robot.logger.debug "file successfully uploaded here: #{client.https(filename)}"
        callRekog msg, filename
      else
        robot.logger.debug res
        robot.logger.error "Upload Error Code: #{res.statusCode}"
        sendRobotResponse msg, title, '[Upload Error]', link
    req.end(content)
