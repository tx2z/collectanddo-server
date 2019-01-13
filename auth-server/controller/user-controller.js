const User = require('../models/user');
const jwt = require('jsonwebtoken');
var request = require('request');

function createToken(user) {
    let credentials;
    if (user == process.env.HASURA_ROLE) {
        credentials = {
            'https://hasura.io/jwt/claims': {
                'x-hasura-default-role': user,
                'x-hasura-allowed-roles': [user],
            }
        };
    } else {
        credentials = {
            id: user.id,
            email: user.email,
            'https://hasura.io/jwt/claims': {
                'x-hasura-user-id': (user.hasuraid).toString(),
                'x-hasura-default-role': 'user',
                'x-hasura-allowed-roles': ['user'],

            }
        };
    }
    return jwt.sign(credentials, process.env.HASURA_GRAPHQL_JWT_SECRET, {
        expiresIn: 86400 // 86400 expires in 24 hours
    });
}

exports.registerUser = (req, res) => {
    if (!req.body.email || !req.body.password) {
        return res.status(400).json({ 'msg': 'You need to send email and password' });
    }

    User.findOne({ email: req.body.email }, (err, user) => {
        if (err) {
            return res.status(400).json({ 'msg': err });
        }

        if (user) {
            return res.status(400).json({ 'msg': 'The user already exists' });
        }

        // Call Hasura API to create user
        const token = createToken(process.env.HASURA_ROLE);
        let data = {
            query: 'mutation insert_user{insert_user(objects: [{name:"' + req.body.email +'"}]) {returning {id}}}',
            variables: null,
            operationName: "insert_user"
        };

        request.post({
            headers: {
                'content-type': 'application/json', 'Authorization': 'Bearer ' + token
            },
            url: process.env.HASURA_URI,
            json: data
        }, function (err, httpResponse, body) {
            if (err) {
                console.log(err);
                return res.status(400).json({ 'msg': 'Error creating user in Hasura' });
            } else {
                if (body.data.insert_user.returning[0].id) {
                    // console.log(body);
                    // console.log(body.data.insert_user.returning[0].id);
                    req.body.hasuraid = body.data.insert_user.returning[0].id;

                    let newUser = User(req.body);
                    newUser.save((err, user) => {
                        if (err) {
                            return res.status(400).json({ 'msg': err });
                        }
                        return res.status(201).json(user);
                    });
                } else {
                    // console.log(body);
                    return res.status(400).json({ 'msg': 'Error creating user in Hasura' });
                }
            }
        }); 


        
    });
};

exports.loginUser = (req, res) => {
    if (!req.body.email || !req.body.password) {
        return res.status(400).send({ 'msg': 'You need to send email and password' });
    }

    User.findOne({ email: req.body.email }, (err, user) => {
        if (err) {
            return res.status(400).send({ 'msg': err });
        }

        if (!user) {
            return res.status(400).json({ 'msg': 'The user does not exist' });
        }

        user.comparePassword(req.body.password, (err, isMatch) => {
            if (isMatch && !err) {
                return res.status(200).json({
                    token: createToken(user)
                });
            } else {
                return res.status(400).json({ msg: 'The email and password don\'t match.' });
            }
        });
    });
};