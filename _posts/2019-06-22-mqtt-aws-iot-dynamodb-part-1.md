---
title: "Tutorial: ESP32 to AWS IoT to AWS DynamoDB (Part I)"
date: 2019-06-22 20:00:00 +08:00
published: yes
tags: [aws, iot, mqtt]
categories: [aws]
---

You read the title, let's get started. For this tutorial, we will be using the [Arduino IDE](https://www.arduino.cc/en/Main/Software). This should be possible with [ESP-IDF](https://github.com/espressif/esp-idf), too, because [ESP-MQTT](https://github.com/espressif/esp-mqtt) is included as part of the ESP-IDF.

# Tested on
This tutorial was created on Ubuntu 18.04.

# Pre-requisites
Before the tutorial begins, please download the following pre-requisites (the version numbers are the versions used to create this tutorial):
- [Arduino IDE](https://www.arduino.cc/) - 1.8.9
- [Python](https://www.python.org/downloads/) - 3.6.8

# Setting up prerequisites
## Arduino IDE

1. Download the [Arduino IDE](https://www.arduino.cc/en/Main/Software) if you don't already have it.
2. Start Arduino, then select **File** > **Preferences**.
    <img src="/images/20190622_21.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="File > Preferences"/>
    <p class="text-center text-gray lh-condensed-ultra f6">File > Preferences | Source: Me</p>
3. Under 'Additional Board Manager URLs', add this URL: `https://dl.espressif.com/dl/package_esp32_index.json`.
    <img src="/images/20190622_22.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Add a board manager url"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Adding a board manager url | Source: Me</p>
4. Goto **Tools** > **Board** > **Boards Manager** and type in `esp32` on the search bar. You should find the esp32 package. Install version `1.0.2`.
    <img src="/images/20190622_23.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Tools > Board > Boards Manager"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Board Manager | Source: Me</p>
    <br/>
    <img src="/images/20190622_24.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Board Manager ESP32 Package"/>
    <p class="text-center text-gray lh-condensed-ultra f6">ESP32 Package | Source: Me</p>
5. Goto **Tools** > **Manage Libraries**. Then, search for `PubSubClient`, and install version `2.7.0`.
    <img src="/images/20190622_25.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Tools > Manage Libraries"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Manage Libraries | Source: Me</p>
    <br/>
    <img src="/images/20190622_26.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Install PubSubClient"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Install PubSubClient library | Source: Me</p> 
6. Select **Tools** > **Board** > _ESP32 Dev Module_. Leave all new options to their default settings.
    <img src="/images/20190622_27.jpg" style="max-width: 500px; width: 100%; margin: 0 auto; display: block;" alt="Tools > Board > ESP32 Dev Module"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Click on it to change the board | Source: Me</p>

## Python

Run through all the installation steps for Python. If you are on Ubuntu, run `sudo apt install python python-serial`.

---

# Linking up ESP32 to AWS IoT
## Step Uno

1. Login to the AWS Management Console.
2. Click on **Services** > **IoT Core** (found under the section "Internet of Things")
    <img src="/images/20190622_1.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Services button on AWS Console" />
    <p class="text-center text-gray lh-condensed-ultra f6">Click on Services | Source: Me</p>
    <br/>
    <img src="/images/20190622_2.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="IoT Core" />
    <p class="text-center text-gray lh-condensed-ultra f6">IoT Core | Source: Me</p>
3. On the sidebar, goto **Secure** > **Policies**, and click on "Create a Policy" or "Create", depending on which one is present.
    <img src="/images/20190622_3.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="IoT Policy" />
    <p class="text-center text-gray lh-condensed-ultra f6">Create IoT Policy | Source: Me</p>
    <br/>
    <img src="/images/20190622_4.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Alternate IoT Policy" />
    <p class="text-center text-gray lh-condensed-ultra f6">If you already have policies, use this button instead | Source: Me</p>
4. A wizard should appear. Name your policy through the _Name_ field, key in `iot:*` into the _Action_ field, key in `*` under the _Resource ARN_ field, and finally, check the 'Allow' box under _Effect_. Should you wish to restrict your policy more for higher security, or prevent other _authorized_ (yes, _authorized_) users from using your topic, please refer to [this AWS Documentation](https://docs.aws.amazon.com/iot/latest/developerguide/iot-policies.html) to construct your own policy. After checking your fields, press **Create**.
    <img src="/images/20190622_5.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Wizard options"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Values for the wizard | Source: Me</p>
5. On the sidebar, goto **Manage** > **Things**, and click on "Register a thing" or "Create" depending on which one is present.
    <img src="/images/20190622_6.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Create button"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Click on Create | Source: Me</p>
    <br/>
    <img src="/images/20190622_7.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Register a thing"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Or click on Register a Thing | Source: Me</p>
6. Click on "Create a single thing".
    <img src="/images/20190622_8.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Create a single thing"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Create a single thing | Source: Me</p>
7. Name your thing whatever you want, and click **Next** at the bottom of the page.
    <img src="/images/20190622_9.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Name and Create"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Name your thing, and press create | Source: Me</p>
8. Click on **One-click certificate creation (recommended)**.
    <img src="/images/20190622_10.jpg" style="max-width: 600px; width: 100%; margin: 0 auto; display: block;" alt="One click certificate creation"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Certificate Creation | Source: Me</p>
9. After a while, the wizard should generate a certificate. Download the certificate, and the private key. Also, get the root CA, here is a [direct link](https://www.amazontrust.com/repository/AmazonRootCA1.pem) to it. Make sure to activate the certificate before clicking **Attach a policy**.
    <img src="/images/20190622_11.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Download certificate, private key, CA"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Download the cert, private key, CA cert, and activate before continuing. | Source: Me</p>
10. Find your policy in the search box, and select it. Then, click **Register Thing**.
    <img src="/images/20190622_12.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Select then register thing"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Register thing | Source: Me</p>
11. Click into the thing you have created.
    <img src="/images/20190622_14.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Click into thing"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Click into the thing you created | Source: Me</p>
12. On the sidebar, click on **Interact**.
    <img src="/images/20190622_15.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Click on interact"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Caption</p>
13. Note down the HTTP Endpoint (both MQTT and HTTP share the same endpoint).
    <img src="/images/20190622_16.jpg" style="max-width: 800px; width: 100%; margin: 0 auto; display: block;" alt="Note this down"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Note down the endpoint | Source: Me</p>
14. Click the grey back arrow in the page and click on **Test** in the sidebar. You should see the MQTT Client as shown below. Keep this window open, and proceed to Step Dos.
    <img src="/images/20190622_13.jpg" style="max-width: 900px; width: 100%; margin: 0 auto; display: block;" alt="MQTT Client"/>
    <p class="text-center text-gray lh-condensed-ultra f6">MQTT Client on AWS IoT Console | Source: Me</p>

## Step Dos

1. Open the Arduino IDE / Switch to the Arduino IDE.
2. Completely replace all the code in the IDE with code [from this gist](https://gist.github.com/jameshi16/7f277bb8dfecf38a30aea0093f30477a).
3. Fill in the configuration options by editing the content within the double quotes (\"):
    - `SSID`: The SSID of the access point to connect to.
    - `Password`: The password of the access point to connect to.
    - `aws_iot_hostname`: The hostname you noted down during Step Uno.
    - `aws_iot_sub_topic`: The topic this device should subscribe to. For this tutorial, we'll use `topic/hello`, however, when following the tutorial with your friends, please have _unique_ topics.
    - `aws_iot_pub_topic`: The topic this device should publish to. For this tutorial, it'll be `another/topic/echo`, however, when following the tutorial with your friends, please have _unique_ topics.
    - `ca_certificate`: Copy the contents of the CA certificate you downloaded (file should be `AmazonRootCA1.pem`) using any text editor like Notepad or Vim, and paste it into the textbox located below this list. Click on `Make into C++ String`, and copy the contents of the textbox into the configuration option.
    - `iot_certificate`: Copy the contents of the certificate you downloaded (file should be `*-certificate.pem.crt`) using any text editor like Notepad or Vim, and paste it into the textbox located below this list. Click on `Make into C++ String`, and copy the contents of the textbox into the configuration option.
    - `iot_privatekey`: Copy the contents of the private key you downloaded (file should be `*-private.pem.key`) using any text editor like Notepad or Vim, and paste it into the textbox located below this list. Click on `Make into C++ String`, and copy the contents of the textbox into the configuration option.
    <form action="javascript:void(0)" onsubmit="magicTextTransformer()" style="margin: 0 auto; max-width: 800px; width: 50%">
	    <textarea id="transformee" style="width: 100%; height: 100px" /><br/>
	     <input type="submit" value="Make into C++ String" style="float: right;"/>
    </form>

    <script type="application/javascript">
	    function magicTextTransformer() {
		    text = document.getElementById('transformee').value;
		    document.getElementById('transformee').value = text.replace(/\n/g, '\\n');
	    }
    </script>
4. Plug in your ESP32 now.
5. Select the port by going into **Tools** > **Port** > COMX or /dev/ttyUSBX, where X is the port to your ESP32.
6. Click on Upload.
7. [Optional] Launch the serial console to see debugging infomration.

## Step Tres

1. Go back to the window highlighted in the last step of Step Uno.
2. For this tutorial, fill in `another/topic/echo` in the _Subscription topic_ textbox, and click on `Subscribe to topic`.
    <img src="/images/20190622_17.jpg" style="max-width: 1000px; width: 100%; margin: 0 auto; display: block;" alt="Subscribe topic"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Subscribe to the topic | Source: Me</p>
3. For this tutorial, fill in `topic/hello` in the _Publish_ textbox, and click on `Publish to topic`.
    <img src="/images/20190622_18.jpg" style="max-width: 1000px; width: 100%; margin: 0 auto; display: block;" alt="Publish to topic"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Publish to the topic | Source: Me</p>
4. If you have done everything correctly so far, you should see a new message popup below the publish block, which is echoed from the device. If you have have your serial console up, you can also see that the message has reached your ESP32.
    <img src="/images/20190622_19.jpg" style="max-width: 1000px; width: 100%; margin: 0 auto; display: block;" alt="Recieved message from ESP32 echo"/> 
    <p class="text-center text-gray lh-condensed-ultra f6">An echo from the ESP32 on AWS IoT | Source: Me</p>
    <br/>
    <img src="/images/20190622_20.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="What the ESP32 recieves"/>
    <p class="text-center text-gray lh-condensed-ultra f6">Serial Console | Source: Me</p>	
5. Clear the text field that contains the JSON, and try publishing either 1 or 0, and observe the ESP32 closely per published message.

---

# Code explanation

The code contains the absolute (mostly) minimal code required to perform MQTT Pub/Sub with AWS IoT MQTT endpoints. Other than the MQTT client verifying the server's identity, AWS also requires that all clients be authenticated with client certificates. Hence, the following lines:
```cpp
client.setCACert(ca_certificate);
client.setCertificate(iot_certificate);
client.setPrivateKey(iot_privatekey);
```
are responsible for setting the required certificates for communication.

Publishing is done like so:
```cpp
mqtt.publish(aws_iot_pub_topic, aws_iot_pub_message);
```
And subscribing is done like so:
```cpp
mqtt.subscribe(aws_iot_sub_topic); //subscribe to the topic
```
Do note that for subscribing, you must provide a callback function with the signature of `void callback(const char* topic, byte* payload, unsigned int length)`. This callback will be called by the `PubSubClient` library whenever there is a new message from the subscribed topics.

MQTT typically uses port `1883` and `8883`. AWS IoT only uses port `8883`, because it uses MQTT over SSL (MQTTS), hence the line:
```cpp
mqtt.setServer(aws_iot_hostname, 8883);
```

---

Hope you enjoyed the tutorial. In part two of this two-parter tutorial, we will be adding a policy that will pipe whatever our ESP32 publishes to AWS IoT into DynamoDB. Until then,

Happy Coding,

CodingIndex
