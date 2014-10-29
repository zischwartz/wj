---
title: The YayTM
date: 2011-01-24 11:11
media: yaytm.png
sum: Calls attention to itself, asks passersby to dance for it, in exchange for a dollar, and internet notoriety
press:
 - link: http://hackaday.com/2011/01/21/dance-for-a-dollar-with-the-yaytm
   text: Hackaday
---

Using face tracking to measure dancing prowess, the the YayTM determines if the user is dancing to its standards and dispenses a dollar if it likes what it sees. Then, regardless of the success or failure of the dancer, and without their previous knowledge, the YayTM uploads video of the dancer to YouTube and displays that video on this webpage for everyone to enjoy. I wanted to explore the devices that bridge the gap between the physical world and the internet in interesting ways.

Check out the videos.

The bill dispenser cost ten dollars on ebay and was manufactured by [ICT](http://www.ict-america.com/product/dispensing_devices.asp). I burned out the circuit board pretty quickly while messing around with it, but the motor continued to work, so with a little cajoling and the installation of my own LED and sensor, I was able to dispense dollar bills using an Arduino and Processing.

<iframe src="http://www.youtube.com/embed/_QA9ehljs1I" frameborder="0" allowfullscreen></iframe>
Above is a video documenting use of the YayTM. This was recorded at the very end of the ITP show (which is why people are cheering) and why the bill dispenser is a little beat up from a full day of use and  wonkily dispensed two dollars instead of one.

Another aspect to this piece was the [EULA](http://en.wikipedia.org/wiki/End-user_license_agreement). On the initial screen ("Shall We Play A Game?"), there's  small print near the bottom, which most people, predictably, didn't seem to notice let alone read, and pressed the button to begin instead.

Like a lot of real world EULAs, it was fairly absurd and abusive, granting the YayTM "all rights to your dignity, image, likeness" The [EFF does good work on EULAs](https://www.eff.org/issues/terms-of-abuse).

The EULA reads:

> END-USER LICENSE AGREEMENT FOR YayTM IMPORTANT PLEASE READ THE TERMS AND CONDITIONS OF THIS LICENSE AGREEMENT CAREFULLY BEFORE CONTINUING WITH THIS PROGRAM : YayTM End-User License Agreement ('EULA') is a legal agreement between you (either an individual or a single entity) and YayTM for the YayTM software product(s) identified above which may include associated software components, media, printed materials, and 'online' or electronic documentation ('SOFTWARE PRODUCT'). By installing, copying, or otherwise using the SOFTWARE PRODUCT, you agree to be bound by the terms of this EULA. This license agreement represents the entire agreement concerning the program between you and YayTM, (referred to as 'licenser'), and it supersedes any prior proposal, representation, or understanding between the parties. If you do not agree to the terms of this EULA, do not install or use the SOFTWARE PRODUCT. You hereby waive all rights to your dignity, image, likeness for use by the YayTM however it shall choose.

