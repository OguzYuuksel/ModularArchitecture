// Project: ModularArchitecture
// File: StringSet.swift
// Copyright © 2022 Oguz Yuksel. All rights reserved.
//
// Created by Oguz Yuksel(oguz.yuuksel@gmail.com) on 21.05.2022.

import Foundation

enum StringSet {

    // MARK: Static Properties
    // Template Variables
    private static let template_ProjectName_base: String = "ProjectName"
    static var template_ProjectName: String { <<>>template_ProjectName_base }
    static var template_projectName: String { <<>>template_ProjectName_base.lowercasedFirst() }
    static var template_projectname: String { <<>>template_ProjectName_base.lowercased() }
    
    private static let template_PackageName_base: String = "PackageName"
    static var template_PackageName: String { <<>>template_PackageName_base }
    static var template_packageName: String { <<>>template_PackageName_base.lowercasedFirst() }
    static var template_packagename: String { <<>>template_PackageName_base.lowercased() }
    
    private static let template_DeveloperNameSurname_base: String = "DeveloperNameSurname"
    static var template_DeveloperNameSurname: String { <<>>template_DeveloperNameSurname_base }

    private static let template_DeveloperMail_base: String = "DeveloperMail"
    static var template_DeveloperMail: String { <<>>template_DeveloperMail_base }
    
    private static let template_YYYY_base: String = "YYYY"
    static var template_YYYY: String { <<>>template_YYYY_base }
    
    private static let template_DDMMYYYY_base: String = "DD.MM.YYYY"
    static var template_DDMMYYYY: String { <<>>template_DDMMYYYY_base }
    
    private static let template_BundlDPrefix_base: String = "BundleIDPrefix"
    static var template_BundlDPrefix: String { <<>>template_BundlDPrefix_base }
    
    // Current Time & Date
    static var date_DDMMYYYY: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY"
        return dateFormatter.string(from: Date())
    }
    static var date_YYYY: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: Date())
    }
}
