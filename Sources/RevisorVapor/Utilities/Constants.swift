//
//  FSRSConfig.swift
//  RevisorVapor
//
//  Created by Arun on 02/07/26.
//

import Foundation

enum FSRSConfigs {
    static let defaultRetention = 0.9
}

enum DBConstants {
    static let revisionItemsPreviewCount = 5
    static let defaultPage = 1
    static let defaultPageSize = 10
}

enum TimeConstants {
    static let secondsPerDay: TimeInterval = 86_400
}

enum ParameterConstants {
    static let id = "id"
    static let rating = "Rating"
}
