# OffRoadHUDiOS2

## Table of Contents
* [General Info](#general-info)
* [Installation](#installation)
* [Requirements](#requirements)

## General Info
A basic HUD for off-pavement driving. The app displays the current vehicle speed as well as the pitch and roll.
This was mainly intended as a personal project to develop my iOS development skills as well as a showcase for my programming skills and style to potential employers.
This is still a work in progress and over time I'll be adding more features.

## Installation
Simply download the project and run in XCode.

## Requirements
* Mac running Xcode 12. 
* iOS device or simulater running iOS 13 or higher. 

<br />

Note: Xcode 12 is still only availible in beta form. 
I chose to use this version because it includes signicant updates to SwiftUI and as this project was partially intended for my own learning it made the most sense to use the latest tools.

<br />
Additionally, keep in mind that if this is run on a simulator the pitch and roll outputs will not function properly as Xcode's simulators do not include a way to simulate changes in device orientation.
Location services also seem to be a little bit finicky in simulator.
