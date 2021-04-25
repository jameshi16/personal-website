---
title: AutoLockdown
date: 2021-04-25 17:22 +0800
published: true
categories: [release, android, app]
tags: [android]
---

Over the weekend, I got a new phone. The phone was capable of many things that I never had access to - but fingerprint sensing wasn't one of them.

It should come as no surprise to some of you that I avoid biometric authentication religiously: this is because the attack vectors are so simple, that it renders the purpose of authentication useless. Here are some reasons why:

1. It is easy to uncover a fingerprint from the surfaces of your phone to be used as moulding to unlock your phone;
2. You can be unconscious when your (physical) finger is being used to unlock your phone;
3. Should the manufacturer of the fingerprint sensor be untrustworthy, your fingerprint data could be stolen; you only have one fingerprint for your entire life, and it is not changeable.

Therefore, I have been using a 14 character password to protect access to my phone for the past three years.

# Reality

In life, there cannot be too much of a good thing; when you are pressed for time, you need to get work done as quickly as possible. Typing a 14 character password might not sound like a time-consuming process on the surface, but one must account for accidental human errors when keying in the password.

Furthermore, with how frequent we unlock our phones during active use, the time taken to unlock the phone accumulates to many hours of frustration, and triggers impatient superiors to no end.

Of course, it is out of the question to simply forgo the use of a locking mechanism - what about all the precious data, banking applications and confidential company documents that you're storing?

Hence, in conclusion, a quick, yet secure method of authentication has a need to exist.

## Evaluation

Let's evaluate the pros and cons of fingerprint authentication, alongside password authentication one more time.

|Feature|Password|Fingerprint|
|:---:|:---:|:---:|
|Fast to unlock|No|**Yes**|
|Secure|Following guidelines, **Yes**|No|
|Changeable|**Yes**|No|
|Lots of apps use it|No|**Yes**|

Many banking apps, and some password managers use fingerprint authentication as a way to quickly unlock an account. As long as you are conscious while you are doing it, such a feature does not sound too bad; after all, it is comparatively safer than typing a 6 digit numerical pin (banking apps) or a 3 alphanumerical pin (KeepassXC for Android) in the public under the prying eyes of many, to quickly unlock your most precious resources.

To solve our dilemma, why not have both fingerprint and password?

# Android Feature: Lockdown Mode

In Android 9 (Pie), there exist a feature known as `Lockdown Mode`. In this mode, "Smart Lock" features are disabled, biometric authentication is disabled, and notifications no longer show. Users who wish to turn on Lockdown Mode can do it through the power menu, after the feature is enabled.

To learn what is Lockdown Mode, and how to enable it for your phone, visit [this screenrant link](https://screenrant.com/android-lockdown-mode-purpose-enable-how-explained/).

Having discovered Lockdown Mode, I gave in to the temptations of the fingerprint, and registered my own biometrics. However, I found that turning on Lockdown Mode is too user-dependent, meaning that there might be times where I am too fatigued to turn on the mode to protect my phone. Hence, I tried automating the process.

# Automation

I downloaded [Automate](https://play.google.com/store/apps/details?id=com.llamalab.automate) and [this nifty app](https://play.google.com/store/apps/details?id=com.radefffactory.lockdown) that provides shortcuts to enable Lockdown mode, and linked it up such that whenever I turn off the screen, a 5 minute timer will go off, which will launch the second app to enable Lockdown mode.

5 minutes is an arbitrarily decided duration - I felt that as long as I tried unlocking my phone again within 5 minutes, a fingerprint would be acceptable. While this does not guarantee the safety of my data if I were to be suddenly robbed, I felt that it would "good enough" to prevent my data from being accessed in my sleep by a sneaky adversary.

While it worked well, the whole setup was clunky and cumbersome; furthermore, I felt like it was too overkill. Having used Tasker and Automate before, I knew that battery consumption might become an issue.

# The creation of AutoLockdown

Hence, to solve all of these problems in one fell swoop, I decided to make an app. The [repository](https://github.com/jameshi16/AutoLockdown) can be found on GitHub; essentially, the phone automatically removes biometric authentication as a possible authentication method after a user-configuration period of time.

In the future, I hope to also add scheduling; so, apart from removing biometric authentication after a set duration, it will be removed during, say, bedtime, as well.

# Conclusion

If you were in the same dilemma as me, I hope you find [AutoLockdown](https://github.com/jameshi16/AutoLockdown) satisfactory; otherwise, go ahead and give me some feedback through <a target="_blank" href="mailto:me@codingindex.xyz">my email</a>!

Happy Coding

CodingIndex
