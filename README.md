# Uthenga -> Messaging Server in Haskell

Uthenga is a simple user-facing messaging server written in Haskell.

# Overview
Uthenga is in an early state (release 0.1). 


The goal of Uthenga is to be a fast message bus for user interaction of data between multiple devices:

* Very easy consumption of messages with web and mobile clients
* Fast realtime messaging, as well as playback of messages from a Disque (Redis)
* Reliable and scalable over multiple nodes
* User-aware semantics to easily support messaging scenarios between people using multiple devices
