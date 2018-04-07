[![Build Status](https://travis-ci.org/phstc/putsreq.svg)](https://travis-ci.org/phstc/putsreq)
[![Code Climate](https://codeclimate.com/github/phstc/putsreq/badges/gpa.svg)](https://codeclimate.com/github/phstc/putsreq)
[![Test Coverage](https://codeclimate.com/github/phstc/putsreq/badges/coverage.svg)](https://codeclimate.com/github/phstc/putsreq/coverage)

## PutsReq

PutsReq lets you record HTTP requests and simulate responses like no other tool available. [Try it now](http://putsreq.com)!

Check this post: [Play Rock-paper-scissors with Slack and PutsReq](http://www.pablocantero.com/blog/2014/10/12/play-rock-paper-scissors-with-slack-and-putsreq/) for some other examples.

### Getting Started

Steps to run PutsReq in development.

#### Install MongoDB

```bash
brew install mongo

mongod
```

#### Start PutsReq

```
cd ~/workspace

git clone git@github.com:phstc/putsreq.git

cd putsreq

bundle install

rails server

open http://localhost:3000
```

### Response Builder

The Response Builder is the place where you can create your responses using JavaScript V8.

Here is the list of request attributes you can access to create your responses:

#### request

```javascript
// curl -X POST -H 'X-MyHeader: MyHeaderValue' -d 'name=Pablo' https://putsreq.com/<YOUR-TOKEN>

request.request_method;
// => POST

request.body;
// => name=Pablo

request.params.name;
// => Pablo

request.headers['HTTP_X_MYHEADER'];
// => MyHeaderValue
```

Parsing a JSON request:

```javascript
// curl -i -X POST -H 'Content-Type: application/json' -d '{"message":"Hello World"}' https://putsreq.com/<YOUR-TOKEN>

var parsedBody = JSON.parse(request.body);

parsedBody.message;
// => Hello World
```

#### response

```javascript
response.status  = 200;  // default value
response.headers = {};   // default value
response.body    = 'ok'; // default value
```

Returning a JSON response:

```javascript
response.headers['Content-Type'] = 'application/json';

response.body = { 'message': 'Hello World' };
```

#### forwardTo

If you only want to log your requests, you can use PutsReq as a proxy to forward them.

```javascript
request.forwardTo = 'http://example.com/api';
```

You can also modify the requests before forwarding them.

```javascript
// add or change a header
request.headers['X-MyNewHeader'] = 'MyHeaderValue'

var parsedBody = JSON.parse(request.body);

// add or change a value
parsedBody['my_new_key'] = 'my new value';

request.body = parsedBody;

request.forwardTo = 'http://example.com/api';
```

### CLI

Want to test Webhook calls against your localhost? PutsReq makes it easy!

You can think of it, as a kind of [ngrok](http://ngrok.io), but instead of creating a tunnel to your localhost, PutsReq polls requests from `YOUR-PUTSREQ-TOKEN` and forwards to your localhost.

```bash
gem install putsreq

putsreq forward --to http://localhost:3000 --token YOUR-TOKEN

Listening requests from YOUR-TOKEN
Forwarding to http://localhost:3000
Press CTRL+c to terminate
2016-12-21 20:49:54 -0200       POST    200
```

### Ajax

PutsReq supports [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing), so you can use it to test your Ajax calls.

```html
<html>
  <head>
    <title>Your Website</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.0/jquery.min.js"></script>
    <script>
    // Sample PutsReq Response Builder
    // https://putsreq.com/<YOUR-TOKEN>/inspect
    // response.headers['Content-Type'] = 'application/json';
    // response.body = { 'message': 'Hello World' };

    // Sample Ajax call
    $.get('https://putsreq.com/<YOUR-TOKEN>', function(data) {
      alert(data.message);
      // => 'Hello World'
    });
    </script>
  </head>
  <body>
  </body>
</html>
```

### Sample Integration Tests

https://github.com/phstc/putsreq_integration_sample

### Production

In production (Heroku), PutsReq runs on mLab sandbox, with a storage of 496 MB. For avoiding getting exceeding the capacity, the `requests` and `responses` collections must be converted into capped collections.

```
db.runCommand({ "convertToCapped": "requests",  size: 15000000 });
db.runCommand({ "convertToCapped": "responses", size: 15000000 });
```

### License

Please see [LICENSE](https://github.com/phstc/putsreq/blob/master/LICENSE) for licensing details.
