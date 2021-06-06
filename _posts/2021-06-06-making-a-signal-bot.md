---
title: Making a Signal bot
date: 2021-06-06 18:38 +0800
published: true
categories: [signal, bot]
tags: [signal]
---

Yes, yes, okay, I get it. I missed the May deadline. Here, calm down and have a coffee :coffee:.

So, I don't have many friends. The friends that I have are... strange, to say the least.

A while ago, I, [ModelConverge](https://modelconverge.xyz/) and [nikhilr](https://nikhilr.io/) migrated to Signal, to escape from the privacy policy change imposed by Whatsapp. While Whatsapp claims that the privacy policy change will only affect Whatsapp Business users, we had already wanted to migrate away from Whatsapp ever since Facebook acquired it; so the policy change by Whatsapp simply acted as a catalyst. We are hence glad to report that we were part of the masses that hugged [Signal to death](https://www.forbes.com/sites/rachelsandler/2021/01/15/so-many-people-are-using-signal-it-caused-an-outage/?sh=7d7968493df2) during a mass migration to the Signal platform, especially after [Elon Musk's tweet](https://twitter.com/elonmusk/status/1347165127036977153?lang=en).

> For those of you living under a rock, Signal is an instant messenger just like Whatsapp. Many people migrated to Signal because: (i) it is [open-source](https://github.com/signalapp), (ii) it is run by a [non-profit organization](https://signalfoundation.org/) and (iii) has [libraries & specifications](https://signal.org/docs/) for developers who want to leverage the Signal protocol or platform to build apps.

# Spark

The Signal messenger is wonderful; but the users - they have too much power. One of my pals, [nikhilr](https://nikhilr.io/) decided to change the group's avatar photo, drastically changing the friendly democratic climate we shared, effectively serving as a declaration of war between all parties involved. What followed was a great group war that is described in history books as the pivotal moment of the greatest creation.

<img src="/images/20210606_1.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Fighting a great war"/>
<p class="text-center text-gray lh-condensed-ultra f6">Fighting a great war in Signal | Source: Me</p>

I couldn't just sit idly by and watch as my enemy won battle after battle, getting foothold after foothold on my sanctuary; hence, as a responsible and perfectly rational adult, I decided to abandon all of the work society had me do, and built a Signal bot to eliminate my enemy's only advantage (free time), and exploit his weakest point (the fact that he is human and hence slower).

<img src="/images/20210606_2.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="The bot in action, but Nikhil disrupts the policy"/>
<p class="text-center text-gray lh-condensed-ultra f6">Using a bot to fight the war | Source: Me</p>

As you can clearly see, before nikhilr decided to remove my privileges to edit the Group Avatar like a true savage undeserving of a respectful knight, my bot fought an admirable battle, stunning my enemies who displayed sheer awe towards my cunning plot.

Today, we won't be building Group Contender Bot; instead, we'll just be making a simple Signal bot, to jog your creativity and get you started.

----

# Considerations

Being a container nerd, I decided that my bot _must_ be setup and run in a container. Automatically, this means that the Signal bot can be run from any platform that can run Docker; furthermore, this would deploy nicely on a home server running most services on `docker-compose`.

When searching for a way to interface with Signal, I found [Signal CLI](https://github.com/AsamK/signal-cli), which exposes a DBus interface for applications to interact with. Hence, all I needed to do was to get a library that could interface with the DBus, like [`pydbus`](https://pypi.org/project/pydbus/).

## DBus

Many Linux applications talk to each other over the System DBus; according to [this StackOverflow post](https://unix.stackexchange.com/a/604398), it is used as an alternative to `sudo`, by allowing a non-privileged application to perform inter-process communication (IPC) to a more privileged application through a bunch of exposed functions. Hence, the system DBus is also the default DBus used by many applications.

Because of the `non-privileged <-> privilege` method of communication, container software do not normally expose the System DBus to guest containers because it would open up a whole array of possible vulnerabilities. Thankfully, when digger deeper as to what DBus actually is, I found out that it is essentially a protocol slapped on top of a UNIX socket, meaning that theoretically, it should be possible to construct my own DBus instance _just_ for Signal communication.

## Python

The beauty of using the DBus to communicate implies that any language under the sun can be used; I decided to go with Python on an impulse with no clear thought; if I were to make a rational choice, I would have selected [Golang](https://golang.org/), for how simple it is to spawn Go routines for multiprocessing.

On the other hand, Python makes the code more understandable to a wider audience, given its simplicity, and how it is the "comfy" language for most people, allowing a wider audience to develop useful Signal bots.

----

# Pre-requisites

So, let us build a Signal bot!

First and foremost, we need to install all of the dependencies. On an Ubuntu system, Signal CLI requires `default-jre`, while the `pydbus` package requires `build-essentials`, `libcairo2-dev` and `libgirepository1.0-dev`. As you can see, for a bot that will run in container, there are quite a lot of dependencies; hence, instead of polluting my otherwise pure host environment, I decided to create a `Dockerfile` to build me an environment that can handle Signal CLI.

```Dockerfile
FROM ubuntu:latest

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y python3 python3-pip default-jre coreutils curl wget libcairo2-dev libgirepository1.0-dev
WORKDIR /tmp
RUN curl -s https://api.github.com/repos/AsamK/signal-cli/releases/latest \
  | grep "browser_download_url.*tar.gz" \
  | cut -d : -f 2,3 \
  | tr -d \" \
  | grep ".gz$" \
  | wget -qi -
RUN mkdir -p /opt/cli && mkdir -p /opt/bot && tar xvf *.tar.gz -C /opt/cli && mv /opt/cli/signal* /opt/cli/signal
WORKDIR /opt/bot
RUN pip install pydbus PyGObject
```

> I adapted the `curl` command from this [GitHub gist](https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8) written by [`@steinwaywhw`](https://gist.github.com/steinwaywhw).

This creates an Ubuntu container with the latest Signal CLI install in `/opt/cli`, and the working directory planted in `/opt/bot`. To use this container for Signal bot development, you will keep some things at hand:

1. A phone number you have SMS access to;
2. A directory to store your Signal secrets;
3. A directory for your bot project;
4. A name for your bot.

Once you have figured out the phone number & directories you want to use, set them in a terminal you'll be using for Signal bot related work:
```
export PHONE_NUMBER="<a phone number, with +countrycode prefixed>"
export SIGNAL_CLI_DATA="<a directory for signal secrets>"
export SIGNAL_BOT_PROJECT="<the directory to your bot project>"
export SIGNAL_BOT_NAME="<any alphanumeric name for your bot>"
alias signal-cli='docker run -v "$SIGNAL_BOT_PROJECT:/opt/bot" -v "$SIGNAL_CLI_DATA:/root/.local/share/signal-cli" -e PHONE_NUMBER="$PHONE_NUMBER" signal-bot:latest /opt/cli/signal/bin/signal-cli'
```

For development purposes, we should first link the Signal CLI to our phone number, so that the bot can send and receive messages. To do this, we first copy + paste the `Dockerfile` to a local directory, and build the Docker image:
```
wget https://gist.githubusercontent.com/jameshi16/71764cc0bac84adda717e9ddb0b44364/raw/2fff57fac78826e17ad097dcb4c7ed1e873ddb1e/Dockerfile
docker build . -t signal-bot:latest
```

Now, if you want to link to a phone number _you already use for daily Signal usage_, then run this command:
```
signal-cli link -n "$SIGNAL_BOT_NAME" > /tmp/output & \sleep 10 && cat /tmp/output | curl -F-=\<- https://qrenco.de && fg
``` 

A QR code should be generated and then printed on your terminal window; scan the result with your phone's Signal messenger. If you don't know how, follow the [guide on the official Signal Support](https://support.signal.org/hc/en-us/articles/360007320551-Linked-Devices).

Your device should be linked.

**Otherwise**, if you want to link a completely new phone number, then run this Signal CLI command through the container:
```
signal-cli -u ${PHONE_NUMBER} register
```

You should receive a SMS with your OTP code to activate Signal. Copy that verification code before running this command:
```
signal-cli -u ${PHONE_NUMBER} verify <insert verification code>
```

# Writing the bot

Now, we move to the stage where we write the bot. No matter what language the bot is written in, the bot needs at least two other running processes:

1. A DBus daemon; and
2. A daemonized Signal CLI process.

Hence, before we can even write the content required for the bot, we must first write an entrypoint script for the Docker container. Luckily, we can quite easily write this script:

`entrypoint.sh`
```bash
#!/bin/bash

set -e

export DBUS_SESSION_BUS_ADDRESS=$(dbus-daemon --session --fork --print-address)

touch /tmp/output.log
/opt/cli/signal/bin/signal-cli -u "${PHONE_NUMBER}" daemon >> /tmp/output.log 2>&1 &
dbus-monitor --session >> /tmp/output.log 2>&1 & # comment this out if you no longer need to monitor the bus
sleep 20s && python3 /opt/bot/script.py >> /tmp/output.log 2>&1 &

tail -f /tmp/output.log
```

The script above assumes that you are executing a bot written in Python, with the entrypoint of that bot within `script.py` of your project folder, and also assumes that you have set the environmental variables right. Let's test it out:

```
alias run_bot="docker run -v \"$SIGNAL_BOT_PROJECT:/opt/bot\" -v \"$SIGNAL_CLI_DATA:/root/.local/share/signal-cli\" -e PHONE_NUMBER=\"$PHONE_NUMBER\" signal-bot:latest ./entrypoint.sh"
wget -O script.py https://gist.githubusercontent.com/jameshi16/71764cc0bac84adda717e9ddb0b44364/raw/fd3fc896bfe56d18741ba84c8c63d00f34c8434b/receive.py
run_bot
```

The script written by `mh-g`, modified by me to use a Session Bus instead, essentially reads every message pumped into Signal out onto the terminal window.

> The purpose of `sleep 20s` is to give Signal CLI some time to: (i) start daemonizing, (ii) connect to the DBus, and (iii) synchronize messages a little before starting the actual script. Sometimes, this takes more than 20s, but for our purposes, it should be good enough. You may sometimes find your bot unresponsive during this stage; but trust me, it'll work _eventually_, after catching up with all of the messages.

Once you have verified the workability of your whole set up, it is time to write code to develop a signal bot. Let's start with the `receive.py` sample code you downloaded to test the workability of your setup:

`script.py`
```python
#!/usr/bin/python3

def msgRcv(timestamp, source, groupID, message, attachments):
  print("msgRcv called")
  print(message)
  return

from pydbus import SessionBus
from gi.repository import GLib

bus = SessionBus()
loop = GLib.MainLoop()

signal = bus.get('org.asamk.Signal', '/org/asamk/Signal')
signal.onMessageReceived = msgRcv

if __name__ == '__main__':
  loop.run()
```

If you've linked the bot to a number that is _already_ using Signal, then you would realize that this piece of code would only work when people other than yourself messages you. If you want to receive _all_ messages, including the ones from yourself, then change:

```diff
def msgRcv(timestamp, source, groupID, message, attachments):
  print("msgRcv called")
  print(message)
  return

+ def msgSyncRcv(timestamp, source, destination, groupID, message, attachments):
+   msgRcv(timestamp, source, groupId, message, attachments)
+   return

...

signal = bus.get('org.asamk.Signal', '/org/asamk/Signal')
signal.onMessageReceived = msgRcv
+ signal.onSyncMessageReceived = msgSyncRcv

if __name__ == '__main__':
```

And then run the bot again with the `run_bot` command.

Let's make the bot respond to commands that start with the `/` prefix, by changing the contents of the `msgRcv` function:

```python
def msgRcv (timestamp, sender, groupID, message, attachments):
  if len(message) > 0 and message[0] == '/':
    signal.sendGroupMessage("{:s} said {:s}".format(sender, message), [], groupID)
  return

```

Now, send a message to the bot with the `/` prefix, and you should see that the bot echos you like a parrot. With that, we now have a basic bot. For more things that the bot can do, check out [Signal CLI's DBus wiki](https://github.com/AsamK/signal-cli/blob/master/man/signal-cli-dbus.5.adoc); all of the functions are available by de-capitalizing the first letter, and then accessing it as a sub-member of the `signal` object. This also includes the DBus signals listed on the manpage.

For a more complete guide, let's make an 8-ball bot, which essentially just returns an 8-ball-esque response based on random probability.

8-ball has [20 different answers](https://en.wikipedia.org/wiki/Magic_8-Ball#Design_and_usage), which can be represented by the following Python list:
```python
responses = ['It is Certain.', 'It is decidedly so.', 'Without a doubt.', 'Yes definitely.', 'You may rely on it.', 'As I see it, yes.', 'Most likely.', 'Outlook good.', 'Yes.', 'Signs point to yes.', 'Reply hazy, try again.', 'Ask again later.', 'Better not tell you now.', 'Cannot predict now.', 'Concentrate and ask again.', 'Don\'t count on it.', 'My reply is no.', 'My sources say no.', 'Outlook not so good.', 'Very doubtful.']
```

For the `msgRcv` function, we basically just choose a random string within the list, and return it whenever we see 8 ball after the `/` prefix:
```python
import random

responses = ['It is Certain.', 'It is decidedly so.', 'Without a doubt.', 'Yes definitely.', 'You may rely on it.', 'As I see it, yes.', 'Most likely.', 'Outlook good.', 'Yes.', 'Signs point to yes.', 'Reply hazy, try again.', 'Ask again later.', 'Better not tell you now.', 'Cannot predict now.', 'Concentrate and ask again.', 'Don\'t count on it.', 'My reply is no.', 'My sources say no.', 'Outlook not so good.', 'Very doubtful.']

def msgRcv (timestamp, sender, groupID, message, attachments):
  if len(message) > 0 and message[0] == '/':
      if '8ball' in message[1:]:
        signal.sendGroupMessage('8ball: ' + random.choice(responses), [], groupID)
  return
```

Full code for `script.py` can be found in [my gist](https://gist.github.com/jameshi16/71764cc0bac84adda717e9ddb0b44364#file-script-py). After editing the script, the bot can be run with:

```
run_bot
```

Now, on Signal, messaging `/8ball` should yield:

<img src="/images/20210606_3.PNG" style="max-width: 200px; width: 100%; margin: 0 auto; display: block;" alt="8 ball response"/>
<p class="text-center text-gray lh-condensed-ultra f6">A response from magical 8 ball | Source: Me</p>

# Docker Compose

The last part is probably the simplest part; writing the `docker-compose.yml` file. The template should be quite self-explanatory:

```yaml
version: '3'
services:
  signal-bot:
    build: https://gist.githubusercontent.com/jameshi16/71764cc0bac84adda717e9ddb0b44364/raw/Dockerfile
    image: signal-bot
    command: /bin/bash -c "./entrypoint.sh"
    volumes:
      - ${SIGNAL_CLI_DATA}:/root/.local/share/signal-cli
      - ${SIGNAL_BOT_PROJECT}:/opt/bot
    environment:
      - PHONE_NUMBER=${PHONE_NUMBER}
```

Then, fill in the relevant details in the `.env` file. If you have not shutdown the terminal you used in the [pre-requisite](#pre-requisite) stage, then you can use this command to generate the `.env` file:
```
echo -e "SIGNAL_CLI_DATA=${SIGNAL_CLI_DATA}\nSIGNAL_BOT_PROJECT=${SIGNAL_BOT_PROJECT}\nPHONE_NUMBER=${PHONE_NUMBER}" > .env
docker-compose config
```

You should see all of the environment variables substituted. If they are all there, then you can run:
```
docker-compose up
```

To see the bot in action; and run:
```
docker-compose up -d
```

To detach it from the terminal, and run it in the background.

# Conclusion

Welp, that was fun! I will make the source code for the Group Avatar Contender bot available soon; but don't count on it to be online after this blog post. Hopefully, this blog post makes up for the missing one you would have otherwise gotten on May. There _should_ be a separate blog post for June; until then, ciao!

Happy Coding,

CodingIndex
