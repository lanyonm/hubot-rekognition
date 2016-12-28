chai = require 'chai'
sinon = require 'sinon'
request = require 'request'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'hubot-rekognition', ->
  robot =
    respond: sinon.spy()
    logger:
      debug: ->
      error: ->
      warning: ->

  beforeEach ->
    @robot = robot
    @msg =
      send: sinon.spy()
      message:
        text: ''

  require('../src/rekognition')(robot)

  it 'registers a listener', ->
    expect(@robot.respond).to.have.been.calledWith /What do you see?/i

  it 'responds correctly when no image is provided', ->
    @robot.respond.args[1][1](@msg)
    expect(@msg.send).to.have.been.calledWith 'Sorry - it doesn\'t look like you gave me an image to look at.'

  it 'responds correctly to a forbidden image url', ->
    sinon.stub(request, 'get').yields(null, {statusCode: 403})
    @msg.message.text = 'What do you see?: https://s3.amazonaws.com/uploads.hipchat.com/something.jpg'
    @robot.respond.args[1][1](@msg)
    expect(@msg.send).to.have.been.calledWith 'Something bad happened... I was not able to successfully fetch the image...'
