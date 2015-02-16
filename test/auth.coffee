

request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require('./libs/user')

key = null

describe 'user', ->
	this.timeout(20000)

	before userLib.manuallyDestroyUser

	it 'sign up', (done) ->
		this.timeout(10000)
		session = request.agent(app)
		session.post("/auth/register").send({
			email: "light24bulbs@gmail.com"
			password: "secretpassword"
			password_confirmation: 'secretpassword'
		}).expect(200).end (err, res) ->
			
			#console.log('login response:', res)
			console.log "created user with response", res.body
			console.log "creation err: ", err
			done(err)


	it 'confirm email', (done) ->
		User.where(email: 'light24bulbs@gmail.com').fetch().then (user) ->
			session = request.agent(app)
			session
			.get("/user/confirm?token=" + user.get('confirmation_token') )
			.expect(302).end (err, res) ->
				console.log "logged in to new session with response", res.body
				console.log "login err: ", err
				User.where(email: 'light24bulbs@gmail.com').fetch().then (confirmed) ->
					expect(confirmed.get('confirmation_token')).to.equal(null)
				#console.log('login response:', res)

					done(err)


	it 'local sign in', (done) ->
		session = request.agent(app)
		session.post("/auth/local").send(
			email: "light24bulbs@gmail.com"
			password: "secretpassword"
		).expect(200).end (err, res) ->
			expect(res.body.token.key).to.exist
			#console.log('login response:', res)
			console.log "logged in to new session with response", res.body
			console.log "login err: ", err
			done(err)

	it 'local sign up on a third party account', (done)->
		User.forge(email:'light24bulbs+prexisting@gmail.com').save().then (user) ->
			request.agent(app).post("/auth/register").send({
				email: "light24bulbs+prexisting@gmail.com"
				password: "secretpassword"
				password_confirmation: 'secretpassword'
			}).expect(200).end (err, res) ->
				
				#console.log('login response:', res)
				console.log "created new password on prexisting user with response", res.body
				console.log "creation err: ", err
				User.where(email:'light24bulbs+prexisting@gmail.com').fetch().then (fetched) ->
					console.log('user was updated to ', fetched)
					expect(fetched.get('password')).to.exist
					done(err)


