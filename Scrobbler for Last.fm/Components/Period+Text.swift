//
//  Period+Text.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 15/03/2023.
//

import Foundation

extension Period {
    var name: String {
        switch self {
        case .week:
            return "Last 7 days"
        case .month:
            return "Last 30 days"
        case .quarter:
            return "Last 90 days"
        case .halfyear:
            return "Last 180 days"
        case .year:
            return "Last 365 days"
        case .overall:
            return "All time"
        }
    }
    
    var subtitle: String {
        switch self {
        case .week:
            return "In the last 7 days"
        case .month:
            return "In the last 30 days"
        case .quarter:
            return "In the last 90 days"
        case .halfyear:
            return "In the last 180 days"
        case .year:
            return "In the last 365 days"
        case .overall:
            return "Of all time"
        }
    }
}

extension LFMPeriod {
    var period: Period {
        switch self {
        case .unknown:
            return .overall
        case .week:
            return .week
        case .month:
            return .month
        case .quarter:
            return .quarter
        case .halfyear:
            return .halfyear
        case .year:
            return .year
        case .overall:
            return .overall
        }
    }
}
