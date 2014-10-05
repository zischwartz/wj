---
title: Squares
date: 2012-05-15 11:32
sum: Vibrant, agency-having tamagotchi + foursquare, for Intel.
media: squares.png
media_style: 'box-shadow: 0px 0px 2px gray;'
---



### What?
**Squares** is a research project which explores the idea of technology having its own desires and learning its own tastes by using data from the Foursquare API and neural networks.

Squares are social organisms that need people to move them around. They develop preferences based on venue data from the foursquare api, and how much 'fun' that square had at the venue. This data is used to train a neural network (venue data as inputs, 'fun' score as output) after each outing.

When a user logs in, the neural net is executed on all nearby venues, which leads to the user's square suggesting places it wants to go. For instance, mine really likes the [Key Foods](https://foursquare.com/v/key-food/4ae3e13bf964a520729921e3) near my apartment.

I'm working with [Fred Truman](http://fredtruman.com/) to build the prototype, which is taking the form of a mobile web application for the moment.

<iframe src="http://player.vimeo.com/video/37782204" width="700" height="481" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen>
</iframe>

Right now, 'fun' is determined in a simplistic way, depending on how much the user interacts with the square. In the future, we'd very much like to add a way for squares to interact with one another, to add another layer of depth.

### Why?
Intel is funding a research group at ITP to explore "Vibrant Technology", which, very simply put, is the idea of viewing technology not as a tool to benefit people, but as a peer, with it's own desires. The group is lead by [Heather Dewey-Hagborg](http://deweyhagborg.com/bio.html) from ITP and [Maria Bezaitis](http://techresearch.intel.com/ResearcherDetails.aspx?Id=164) from Intel.

### Nerd Stuff
*  Squares backend is written in python using django
*  For the neural nets we're using [FANN](http://leenissen.dk/fann/wp/) which is great, though I wouldn't reccomend the python bindings. It's pretty hacky. Or maybe it's fine, and all my trouble is due to not being a [Swig](http://www.swig.org/) expert.
* Lots of javascript, css, and possibly [sammyjs](http://sammyjs.org/).
* And of course, the Foursquare API.

![Square Shot](/static/img/square_shot.png)


<strike>We'll have a public demo up soon.</strike>


<strike> Demo at totalsquares.com </strike>.

[Source on github](https://github.com/zischwartz/squares).
