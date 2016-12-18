chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'hubot-rekognition', ->
  robot =
    respond: sinon.spy()

  beforeEach ->
    @robot = robot
    @msg =
      reply: sinon.spy()

  require('../src/rekognition')(robot)

  it 'registers a listener', ->
    expect(@robot.respond).to.have.been.calledWith(/What do you see?/i)
