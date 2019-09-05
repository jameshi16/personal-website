---
title: "Tutorial: ESP32 to AWS IoT to AWS DynamoDB (Part III)"
date: 2019-09-06 03:30:00 +08:00
published: yes
tags: [aws, iot, mqtt]
categories: [aws]
---

In theory, this tutorial is out of scope if we're talking about the title; however, this tutorial is crucial, because it completes the entire IoT stack. In this tutorial, you will be building on whatever you have done in [Part I](/2019/06/22/mqtt-aws-iot-dynamodb-part-1/) and [Part II](/2019/09/05/mqtt-aws-iot-dynamodb-part-2/), to build application logic that makes decisions and commands the IoT actuators based on information obtained via sensors.

# Pre-requisites

The previous tutorials, [Part I](/2019/06/22/mqtt-aws-iot-dynamodb-part-1/) and [Part II](/2019/09/05/mqtt-aws-iot-dynamodb-part-2/), must be done.

# Step One

1. Login to the AWS Mangement Console.
2. Click on **Services** > **IAM** (found under the section "Security, Identity & Compliance).
    <img src="/images/20190905_15.jpg" style="max-width: 900px; width: 100%; margin: 0 auto; display: block;" alt="AWS IAM"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Click on IAM | Source: Me</p>
3. On the sidebar, click on **Roles**.
    <img src="/images/20190905_16.jpg" style="max-width: 200px; width: 100%; margin: 0 auto; display: block;" alt="Roles"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Roles | Source: Me</p>
4. Click on **Create role**.
    <img src="/images/20190905_17.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Create role"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Create a role | Source: Me</p>
5. Click on **Lambda** under the **Choose the service that will use this role**. Then, click on **Next: Permissions**.
    <img src="/images/20190906_1.jpg" style="max-width: 900px; width: 100%; margin: 0 auto; display: block;" alt="Choosing the service to use the role"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Choosing the service to use the role | Source: Me</p>
6. Search and select the policies: "AWSLambdaBasicExecutionRole", "AmazonDynamoDBFullAccess", and "AWSIoTDataAccess" from the policy search bar. Then, click **Next: Tags**.
    <img src="/images/20190906_2.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="AWSLambdaBasicExecutionRole"/>
    <p class="text-center text-gray lh-condensed-ultra f6">AWSLambdaBasicexecutionRole | Source: Me</p>
    <br/>
    <img src="/images/20190906_3.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="AmazonDynamoDBFullAccess"/>
    <p class="text-center text-gray lh-condensed-ultra f6">AmazonDynamoDBFullAccess | Source: Me</p>
    <br/>
    <img src="/images/20190906_4.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="AWSIoTDataAccess"/>
    <p class="text-center text-gray lh-condensed-ultra f6">AWSIoTDataAccess | Source: Me</p>
7. Click on **Next: Review**.
    <img src="/images/20190905_20.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Next: Review"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Next: Review | Source: Me</p>
8. Name the role whatever you wish (Field: _Role name_). For the purposes of this tutorial, it will be named "lambda-role". Then, click on **Create role**.
    <img src="/images/20190906_5.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Create the role with a name"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Create the role with a name | Source: Me</p>
9. Click on **Services** > **Lambda** (found under the section "Compute")
    <img src="/images/20190906_6.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Lambda"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Click on Lambda | Source: Me</p>
10. Click on **Create a function** if you are a new user, or **Create function** if you already have some lambda functions on your account.
    <img src="/images/20190906_7.jpg" style="max-width: 900px; width: 100%; margin: 0 auto; display: block;" alt="Create a function (new users)"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Creating a function for new users | Source: Me</p>
    <br/>
    <img src="/images/20190906_8.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Create a function (existing users)"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Creating a function for existing users | Source: Me</p>
11. Name the function whatever you wish (Field: _Function name_). For the purposes of this tutorial, it will be named "iot-lambda". Then, select the role created earlier in step 9, under the **Existing role** dropbox. You may have to click a dropdown link (**Choose or create an execution role**) to reach this setting. Finally, click on **Create function**.
    <img src="/images/20190906_9.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Fill in the fields, and create the function"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Fill in the fields, and create the function | Source: Me</p>
12. Fill the code editor with code from [this gist](https://gist.github.com/jameshi16/851dc9de904811c1b2304cfc1f819f1d).
    <img src="/images/20190906_10.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Fill in the code for the lambda function"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Fill in the code for the lambda function | Source: Me</p>
13. Set the environment variables, `TABLE_NAME`, `IOT_ENDPOINT`, and `IOT_PUBLISH_TOPIC` based on the DynamoDB table name, your IoT endpoint, and the topic subscribed by the ESP32.
    <img src="/images/20190906_11.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Environment Variables"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Set environment variables | Source: Me</p>
14. Click on **Save**, at the top right of the screen.
    <img src="/images/20190906_12.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Click on Save"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Save the lambda function | Source: Me</p>
15. Click on **Services** > **IoT Core** (found under the section "Internet of Things")
    <img src="/images/20190622_1.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Services button on AWS Console" />
    <p class="text-center text-gray lh-condensed-ultra f6">Click on IoT Core | Source: Me</p>
    <br/>
    <img src="/images/20190622_2.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="IoT Core" />
    <p class="text-center text-gray lh-condensed-ultra f6">IoT Core | Source: Me</p>
16. On the sidebar, click on **Act**
    <img src="/images/20190905_7.jpg" style="max-width: 200px; width: 100%; margin: 0 auto; display: block;" alt="Act button on IoT Core"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Act | Source: Me</p>
17. Click on the IoT rule you have created in Part II. If you have not done part II, please do [it now](/2019/09/05/mqtt-aws-iot-dynamodb-part-2/).
    <img src="/images/20190906_13.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Click on the IoT rule created previously"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Click on IoT rule created previously</p>
18. Click on **Add Action**, under the **Actions** section.
    <img src="/images/20190906_14.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Add another action"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Add another action | Source: Me</p>
19. Select **Send a message to a Lambda function**, and click on **Configure Action** at the bottom of the page.
    <img src="/images/20190906_15.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Add a lambda action"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Adding a lambda action | Source: Me</p>
20. Under the _Function name_ field, click on **Select**, then find the function created earlier in step 11, and click **Select** on the corresponding entry. Finally, click on **Add Action**.
    <img src="/images/20190906_16.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Select the correct lambda"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Select the correct lambda function | Source: Me</p>

# Step Two

Similar to how it was done in [Part II](/2019/09/05/mqtt-aws-iot-dynamodb-part-2/), go to the DynamoDB table and refresh the contents. Count the number of records currently on the table, and press the 'BOOT' button on the ESP32 until that count reaches a multiple of 10. The led of the ESP32 should light up only when there is a multiple of 10, otherwise, it will be turned off.

The [lambda script](https://gist.github.com/jameshi16/851dc9de904811c1b2304cfc1f819f1d) you pasted earlier is in charge of causing this to happen; firstly, it will obtain device data. Then, it will make a decision based on the device data; in this case, "is the number of records a multiple of 10? If so, turn on the led, else, turn it off".

Try connecting multiple ESP32s to the same topics, and see what happens when one of the devices are used to make the number of records reach a multiple of 10!

# Conclusion

Congratulations! You have made a full IoT application, starting from Part I: Controlling stuff, to Part II: Collecting data and finally, to Part III: Making decisions. Experiment with this a little bit more, and build the next big thing; you now have the basic skills required to do that on AWS!

If you found this trilogy useful, please do share it with your friends.

Until next time!

Happy Coding,

CodingIndex
