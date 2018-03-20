//
//  SKSConfiguration.swift
//  SpeechKitSample
//
//  All Nuance Developers configuration parameters can be set here.
//
//  Copyright (c) 2015 Nuance Communications. All rights reserved.
//

import Foundation

// All fields are required.
// Your credentials can be found in your Nuance Developers portal, under "Manage My Apps".

var SKSAppKey = "0f7ad50784c7ba3c58b31f51f22913ba2399618e265fb08b1f4be511080fac1789811e0d49d84aa18b69f27e920538b69f9a44c5f9f551184036294845d65fce"
var SKSAppId = "NMDPTRIAL_sitefeng20140825183000"
var SKSServerHost = "lso.nmdp.nuancemobility.net"
var SKSServerPort = "443"

var SKSServerUrl = String(format: "nmsps://%@@%@:%@", SKSAppId, SKSServerHost, SKSServerPort)

var SKSLanguage = "eng-USA"

// Only needed if using Mix.nlu
var SKSNLUContextTag = "!NLU_CONTEXT_TAG!"

