//
//  Result.swift
//  RAround
//
//  Created by Kostiantyn Gorbunov on 12/09/2019.
//  Copyright © 2019 Kostiantyn Gorbunov. All rights reserved.
//

import Foundation

enum Result<ResultType> {
    case results(ResultType)
    case error(Error)
}
