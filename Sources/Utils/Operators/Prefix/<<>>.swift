// Project: ModularArchitecture
// File: <<>>.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 25.05.2022.

import Foundation

prefix operator <<>>
prefix func <<>>(lhs: String) -> String {
    return "<<\(lhs)>>"
}
