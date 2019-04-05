---
layout: post
title: "AWS API Gateway Websockets with AWS Lambda"
date: 2019-03-31 20:00 +08:00
tags: [fix, aws, lambda, connection, websockets, gateway, python]
categories: [aws, python]
published: true
---

While working on a hackathon project, I had difficulty getting AWS Lambda to communicate with API Gateway's (relatively) new WebSocket Connection URL (which has the form of: `https://<api gateway id>.execute-api.<region>.amazonaws.com/<stage>/@connections`), 

# Environment
At the time of writing, AWS Lambda provides the following [environments](https://docs.aws.amazon.com/lambda/latest/dg/current-supported-versions.html) that I use:
- Python 3.7
- Boto3 1.12.42

# What I tried to do
1. [Boto3's](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/apigatewaymanagementapi.html) `ApiGatewayManagementApi`:
  - Didn't work, because AWS Lambda runs some weird version of Boto3, because despite the version number being higher than the documentation I consulted (v1.9.125), AWS Lambda's Boto3 doesn't have `ApiGatewayManagementApi`. Maybe it is only available on an offline installation of Boto3, but I didn't have :clock10:, so I couldn't test it out.
2. Looking at the code required for [implementing AWS SigV4](https://docs.aws.amazon.com/general/latest/gr/sigv4-signed-request-examples.html):
  - Because AWS Services sometimes need SigV4 so that only authenticated requests are executed;
  - Hence, AWS API Gateway's WebSocket Connection URL requires requests signed with SigV4;
  - However, this is way too low-level for something I'm trying to hack in 4 hours;
  - So I didn't do this in the end. This would have worked, if I had enough :clock10: and patience.
3. Adding a Boto3 [layer](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html) on AWS Lambda:
  - Layers are like packages for AWS Lambda;
  - However, the Boto3 version probably isn't the issue, because the Boto3 on AWS Lambda has a higher version number compared to the documentation I referred to;
  - Moreover, I didn't want to upload an entire installation of Boto3;
  - And more pressingly, I didn't have :clock10: to do the above.
4. Adding a SigV4 layer [using the code written by David Muller](https://github.com/DavidMuller/aws-requests-auth) or [the one by jmenga](https://github.com/jmenga/requests-aws-sign):
  - Which would have worked, but I found another solution almost immediately after that.

# What worked
On the [StackOverflow post](https://stackoverflow.com/questions/38144273/making-a-signed-http-request-to-aws-elasticsearch-in-python) that (3) and (4) came from, there was one very underrated solution by `b.b3rn4rd`:

```python
import boto3
import botocore.credentials
from botocore.awsrequest import AWSRequest
from botocore.endpoint import BotocoreHTTPSession
from botocore.auth import SigV4Auth

params = '{"name": "hello"}'
headers = {
  'Host': 'ram.ap-southeast-2.amazonaws.com',
}
request = AWSRequest(method="POST", url="https://ram.ap-southeast-2.amazonaws.com/createresourceshare", data=params, headers=headers)
SigV4Auth(boto3.Session().get_credentials(), "ram", "ap-southeast-2").add_auth(request)    


session = BotocoreHTTPSession()
r = session.send(request.prepare())
```
<p class="text-center text-gray lh-condensed-ultra f6">Credit: <code>b.b3rn4rd</code> from <a href="https://stackoverflow.com/questions/38144273/making-a-signed-http-request-to-aws-elasticsearch-in-python">StackOverflow</a></p>

The problem with the above code is that `BotocoreHTTPSession` no longer exists in newer versions of Botocore (and by extension, Boto3), and so I dived into the source code of Boto3 and botocore to find a drop-in replacement: `URLLib3Session`,

Changing the code to work with API Gateway's WebSockets Connection URL, this is what I've got:
```python
import boto3
from botocore.awsrequest import AWSRequest
from botocore.httpsession import URLLib3Session
from botocore.auth import SigV4Auth

session = URLLib3Session()
data = # insert your data here

request = AWSRequest(method="POST", url="https://<api gateway id>.execute-api.<region>.amazonaws.com/<stage>/@connections/<connection id>", headers={'Host': '<api gateway id>.execute-api.<region>.amazonaws.com'}, data=json.dumps(data))
SigV4Auth(boto3.Session().get_credentials(), "execute-api", <region>).add_auth(request)
session.send(request.prepare())

```

With that, AWS Lambda can now interface with the AWS API Gateway WebSockets Connection URL, and can contact clients connected to the API Gateway via WebSockets. This allowed me to create a real-time dashboard that displays data from AWS DynamoDB streams, which are updated according to create/update/delete events happening to a DynamoDB table.

Well then, time use this knowledge to build the real-time app of your dreams!

Happy Coding,

CodingIndex
