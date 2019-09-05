---
title: "Tutorial: ESP32 to AWS IoT to AWS DynamoDB (Part II)"
date: 2019-09-05 20:30:00 +08:00
published: yes
tags: [aws, iot, mqtt]
categories: [aws]
---

Finally, the long-awaited (2 months) part II is here!

## Pre-requisites

You must have completed [Part I](/2019/06/22/mqtt-aws-iot-dynamodb-part-1/) to continue with this tutorial, as this tutorial builds on the previous tutorial.

## Linking up AWS IoT to DynamoDB

In the previous part, the ESP32 was linked to DynamoDB via MQTT, and it was possible to control the LED of the ESP32 by publishing a message via the AWS IoT testing console to the subscribed IoT topic. However, IoT is much more than just controlling devices from the cloud. There are some devices, known as "IoT Sensors", which are able to report sensor data to the internet. Combined with the ability to control devices and with the massive power of Cloud Computing, this allows more powerful machines to make decisions based on the data collected from the sensors, then returning those results as commands to control devices based on inferences made from aforementioned data.

We can then integrate advanced computing techniques like Big Data and Machine Learning with IoT to better improve lives based around IoT products in a household. This vaguely composites into what is known as "Smart Home"; using a cluster of IoT sensors and actuators to: (i) cut utility bills, (ii) make living more convenient, and (iii) make living more entertaining ([AndroidAuthority](https://www.androidauthority.com/what-is-a-smart-home-806483/), 2019). Scale that to the size of a city, and the term becomes "Smart City", making payments, transport, security, et. cetera more convenient.

Therefore, in this section, you will be modifying your handiwork in Part I to make it such that the ESP32 would publish a JSON object indicating that a button on the ESP32 has been pressed. This JSON object will then be mapped as columns on a DynamoDB table.

Looking at the ESP32 schematics:
<img src="/images/20190905_1.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Schematics for the 'BOOT' button"/>
<p class="text-center text-gray lh-condensed-ultra f6">The schematics for the 'BOOT' button | <a href="https://dl.espressif.com/dl/schematics/ESP32-Core-Board-V2_sch.pdf">Source</a></p>

It appears that the 'BOOT' active-low button can be used as a typical button, which is perfect for the current use case.

### Step Ichi

1. Login to the AWS Management Console.
2. Click on **Services** > **DynamoDB** (found under the section "Database")
    <img src="/images/20190905_2.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="DynamoDB is under the Database Section"/>
    <p class="text-center text-gray lh-condensed-ultra f6">DynamoDB | Source: Me</p>
3. If you've created a DynamoDB table before, you may see a different resultant screen. Click on **Create table**.
    <img src="/images/20190905_3.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="New user DynamoDB"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Click this if you don't already have a table | Source: Me</p>
    <img src="/images/20190905_4.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Existing user DynamoDB"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Click this instead if you already have tables | Source: Me</p>
4. Fill in _Table name_ with whatever name you wish. For the purposes of this tutorial, it will be called "iot-table". Call the partition key "uid", as we will be generating a random UID per record. Then, click **Create**.
    <img src="/images/20190905_5.jpg" style="max-width: 900px; width: 100%; margin: 0 auto; display: block;" alt="Table Creation Wizard"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Table Creation Wizard | Source: Me</p>
5. Click on **Services** > **IAM** (found under the section "Security, Identity & Compliance)
    <img src="/images/20190905_15.jpg" style="max-width: 900px; width: 100%; margin: 0 auto; display: block;" alt="AWS IAM"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Click on IAM | Source: Me</p>
6. On the sidebar, click on **Roles**
    <img src="/images/20190905_16.jpg" style="max-width: 200px; width: 100%; margin: 0 auto; display: block;" alt="Roles"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Roles | Source: Me</p>
7. Click on **Create role**.
    <img src="/images/20190905_17.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Create role"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Create a role | Source: Me</p>
8. Click on **IoT** under the **Choose the service that will use this role**. Then, click on **IoT** under the **Select your use case**. Finally, click on **Next: Permissions**.
    <img src="/images/20190905_18.jpg" style="max-width: 900px; width: 100%; margin: 0 auto; display: block;" alt="Choosing the service to use the role"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Choosing the service to use the role | Source: Me</p>
9. Click on **Next: Tags**.
    <img src="/images/20190905_19.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Next: Tags"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Next: Tags | Source: Me</p>
10. Click on **Next: Review**
    <img src="/images/20190905_20.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Next: Review"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Next: Review | Source: Me</p>
11. Name the role whatever you wish (Field: _Role name_). For the purposes of this tutorial, it will be named "iot-role". Then, click on **Create role**.
    <img src="/images/20190905_21.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Create the role with a name"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Create the role with a name | Source: Me</p>
12. Click on the role you have just created.
    <img src="/images/20190905_22.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Click on the role you have just created"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Click the role you have just created | Source: Me</p>
13. Click on **Attach policies**.
    <img src="/images/20190905_23.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Click on Attach policies"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Attach Policies | Source: Me</p>
14. On the search bar, type "DynamoDB", and select the **AmazonDynamoDBFullAccess** policy. Then, click **Attach policy**.
    <img src="/images/20190905_24.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Search and select the policy"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Search and select <b>AmazonDynamoDBFullAccess</b> | Source: Me</p>
15. Click on **Services** > **IoT Core** (found under the section "Internet of Things")
    <img src="/images/20190622_1.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Services button on AWS Console" />
    <p class="text-center text-gray lh-condensed-ultra f6">Click on IoT Core | Source: Me</p>
    <br/>
    <img src="/images/20190622_2.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="IoT Core" />
    <p class="text-center text-gray lh-condensed-ultra f6">IoT Core | Source: Me</p>
16. On the sidebar, click on **Act**
    <img src="/images/20190905_7.jpg" style="max-width: 200px; width: 100%; margin: 0 auto; display: block;" alt="Act button on IoT Core"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Act | Source: Me</p>
17. If you have not created a AWS IoT Rule before, click on "Create a rule". Otherwise click "Create".
    <img src="/images/20190905_8.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Create a rule (new user)"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Create a rule (new user) | Source: Me</p>
    <img src="/images/20190905_9.jpg" style="max-width: 200px; width: 100%; margin: 0 auto; display: block;" alt="Create a rule (existing user)"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Create a rule (existing user) | Source: Me</p> 
18. Name the rule (the _Name_ field). For the purposes of this tutorial, it will be named "dynamodb\_rule".
    <img src="/images/20190905_10.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Rule Name"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Name the rule whatever you want | Source: Me</p>
19. In the _Rule query statement_, use this SQL statement:
    ```sql
    SELECT newuuid() AS uid, timestamp() AS timestamp, * FROM 'another/topic/hello'
    ```
    <img src="/images/20190905_11.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="SQL Query"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Put the SQL statement into the <i>Rule query statement</i> field | Source: Me</p>
20. Click on **Add action** under the **Set one or more actions** section.
    <img src="/images/20190905_12.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="SQL Actions"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Click on the Add Action button | Source: Me</p>
21. Check the **Split message into multiple columns of a DynamoDB table (DynamoDBv2)** option, and scroll down to click **Configure action** button.
    <img src="/images/20190905_13.jpg" style="max-width: 600px; width: 100%; margin: 0 auto; display: block;" alt="Option + Configure action button"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Configure the action | Source: Me</p>
22. Select the corresponding _Table name_ created in step 4. Select the corresponding role created in step 11, by first clicking on **Select**, then selecting the role with the subsequent **Select** button. Finally, click **Add action**.
    <img src="/images/20190905_14.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Select the correct table name and IAM role"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Table name, and IAM role | Source: Me</p>
23. Back on the rule creation wizard, click on **Create rule**.
    <img src="/images/20190905_25.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Create the rule"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Create the rule | Source: Me</p>

### Step Ni

Now that the AWS services are setup properly, it is time to update the Arduino code. Replace (or selectively replace, if you know what you're doing) the old code with new code from [this gist](https://gist.github.com/jameshi16/5846acdec40279028319c680fe8314b5). Here is the summary of the changes made since the previous Arduino program:

- Recieving a message from the subscription topic no longer echos to the publishing topic;
- Button is programmed to send a message (a JSON object containing the state of the LED) to the publishing topic.

Ensure that the `ssid`, `password`, `aws_iot_hostname`, `aws_iot_sub_topic`, `aws_iot_pub_topic`, `ca_certificate`, `iot_certificate` and `iot_privatekey` are filled in correctly, as described in the [previous tutorial](/2019/06/22/mqtt-aws-iot-dynamodb-part-1/)'s Step Dos.

Plug in the ESP32, select the port, and upload. Open the serial console to see debugging information, if desired.

### Step San

1. Go back to the AWS Console, and revisit **Services** > **DynamoDB**.
    <img src="/images/20190905_2.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="DynamoDB is under the Database Section"/>
    <p class="text-center text-gray lh-condensed-ultra f6">DynamoDB | Source: Me</p>
2. On the sidebar, click on **Tables**
    <img src="/images/20190905_26.jpg" style="max-width: 200px; width: 100%; margin: 0 auto; display: block;" alt="Click on tables"/>
    <p class="text-center text-gray lh-condensed-ultra f6">DynamoDB sidebar | Source: Me</p>
3. Click on the table you created, and then click on the **Items** tab.
    <img src="/images/20190905_27.jpg" style="max-width: 600px; width: 100%; margin: 0 auto; display: block;" alt="View items in the table"/>
    <p class="text-center text-gray lh-condensed-ultra f6">View items in the table | Source: Me</p>
4. On the physical ESP32 device, press and release the 'BOOT' button once.
    <img src="/images/20190905_28.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="The boot button"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Press this button once | Source: Me</p>
5. Click on the refresh icon, located on the top right of the DynamoDB items table. You should see a new entry. Try pressing the 'BOOT' button on the ESP32 device a couple more times to see new records coming in.
    <img src="/images/20190905_29.jpg" style="max-width: 600px; width: 100%; margin: 0 auto; display: block;" alt="The refresh button"/>
    <p class="text-center text-gray lh-condensed-ultra f6">The refresh button | Source: Me</p>
6. Ensure that previous functionality of turning on / off the LED through the subscription topic still works.

# What did I just do?

Now, you have a means to control a device, **and** a means to get device information from the ESP32. If all you need is to store the state of IoT things, including the state history, AWS IoT provides a feature to do just that - it is known as "Shadow Document", which allows an IoT device to be stateless while reporting information to AWS IoT, which can keep track of state. You can learn more about that [here](https://docs.aws.amazon.com/iot/latest/developerguide/device-shadow-document.html).

However, for our application, we want to process data as it comes in; computing something from the device information so that we can control the said device. Hence, we don't have a need for the Shadow Document; instead, we opted to use a database like DynamoDB. You can learn more about DynamoDB [here](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html).

Hence, we still have a missing step; the part where we process the data. (Part III? _wink wink_)

# Conclusion

IoT is an important topic, and should be accessible to everyone. Studying IoT not only includes learning how to actually implement it, but includes other important aspects, such as security (our solution is not very secure, to make it easier to achieve certain steps), connectivity, and scaling.

Do look out for Part III!

Happy Coding,

CodingIndex
