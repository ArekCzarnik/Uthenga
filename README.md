# Uthenga -> Messaging Server in Haskell

Uthenga is a simple user-facing messaging server written in Haskell.

[![Build Status](https://circleci.com/gh/ArekCzarnik/Uthenga.svg?style=shield&circle-token=c7a64cfa4a1279a9a3d2a0e67209394ea3cafddf)](https://circleci.com/gh/ArekCzarnik/Uthenga.svg?style=shield)
[![Coverage Status](https://coveralls.io/repos/github/ArekCzarnik/Uthenga/badge.svg?branch=master&service=github)](https://coveralls.io/repos/github/ArekCzarnik/Uthenga/badge.svg?branch=master)


# Overview
Uthenga is in an very early state (release 0.1). 

The goal of Uthenga is to be a fast message bus for user interaction of data between multiple devices:

* Very easy consumption of messages with web and mobile clients
* Fast realtime messaging, as well as playback of messages from a Disque (Redis).
* Reliable and scalable over multiple nodes
* User-aware semantics to easily support messaging scenarios between people using multiple devices

# Technical Overview

* using plain old mysql for persistence
* for task scheduler disque
* twilio for sms sending

* https://github.com/markandrus/twilio-haskell
* https://github.com/winterland1989/mysql-haskell
* https://github.com/creichert/disque.hs
* https://github.com/snoyberg/http-client