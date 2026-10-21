# hubot-rekognition
-----------
> [!WARNING]
> **This project is no longer maintained** and has been archived. It was last updated in 2016 and targets Hubot 2.x. Its dependencies are out of date and have known vulnerabilities: AWS SDK for JavaScript v2 is past end-of-support, and `request` and `knox` are deprecated. It's kept for reference only.

A hubot script that will run an image through the [AWS Rekognition](https://aws.amazon.com/rekognition/) detectLabels function.

See [`src/rekognition.coffee`](src/rekognition.coffee) for full documentation.

## Installation

In your hubot project repo, run:

`npm install hubot-rekognition --save`

Then add **hubot-rekognition** to your `external-scripts.json`:

```json
["hubot-rekognition"]
```

## Configuration
`hubot-rekognition` requires a bit of configuration in the form of environment variables to get everything working:

* `HUBOT_S3_BUCKET` - the S3 bucket you'd like to upload images to
* `HUBOT_AWS_ACCESS_KEY_ID` - an AWS access id with access to S3 and Rekognition
* `HUBOT_AWS_SECRET_ACCESS_KEY` - a matching AWS secret key
* `HUBOT_AWS_REGION` - the AWS region you'd like to use. eg: 'us-west-2'

## Sample Interaction

```
user1>> @hubot What do you see? <picture>
hubot>> I think I see: Electronics (80.4%), Monitor (80.4%), Screen (80.4%)...

```

## TODO

- [ ] Remove dependency on `knox`
- [ ] Create more meaningful tests
- [ ] Experiment with [Bytes](http://docs.aws.amazon.com/rekognition/latest/dg/API_Image.html) instead of S3Bucket
