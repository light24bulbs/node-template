request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require './libs/user'
userLib.createHooks()

describe 'user', ->
	it 'should get info', (done)->
		userLib.login {}, (session, token) ->
			session.post("/user/info").send({
				token: token
			}).expect(200).end (err, res) ->
				
				#console.log('login response:', res)
				console.log('user info:', res.body)
				expect(res.body).to.exist
				done(err)

	it 'should generate password reset token', (done)->
		this.timeout 15000
		userLib.getUser().then (user) ->
			user.sendPasswordReset () ->
				done()


	it 'should reset password using a valid reset token', (done) ->
		userLib.getUser().then (user) ->
			user.related('tokens').create(type:'reset').then (token) ->
				request.agent(app).post("/user/resetpassword").send({
					key: token.get('key')
					password: 'resetpassword'
					password_confirmation: 'resetpassword'
				}).expect(200).end (err, res) ->
					console.log('reset password with respoonse', res.body)
					userLib.getUser().then (user) ->
						expect(user.validPassword('resetpassword')).to.equal(true)
						done(err)
