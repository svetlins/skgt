WHAT IT IS
----------

SKGT Mobile Frontend for gps data about public transport in Sofia taken from
http://gps.skgt-bg.com

DEMO
----
See live demo [here](http://skgt.heroku.com/main.html)

WEBKIT
------

This is a mobile frontend targeting mobile WebKit. Tested on iOS and Android
devices. Otherwise mostly works with any browser(the latest versions) except, of
course IE

WHAT TO EXPECT
--------------

*   ability to link to particular lines / routes / bus stops
*   relative arrival times, instead of absolute

CODE REQUIREMENTS
------------

ruby (tested on 1.8.7 and heroku) and the following gems:

*   sinatra
*   json
*   nokogiri

skgt.rb
-------

This file is a mess, reflecting the absolutely shitty ASP backend SKGT uses
and me not having very bright ideas that particular morning :).
It works as of now but I promise one day I'll rewrite it.
