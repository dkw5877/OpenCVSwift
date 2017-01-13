//
//  Evaluate.swift
//  OpenCVSwift
//
//  Created by user on 1/11/17.
//  Copyright © 2017 someCompanyNameHere. All rights reserved.
//

import Foundation

protocol Evaluate {
    func evaluateAt(position:Double) -> Double
}

class BezierEvaluator: Evaluate {

    let firstControlPoint:Double
    let secondControlPoint:Double

    init(first:Double, second:Double) {

        firstControlPoint = first
        secondControlPoint = second
    }

    func evaluateAt(position:Double) -> Double {

        // (1 - position) * (1 - position) * (1 - position) * 0.0 +
        let curve =  3 * position * (1 - position) * (1 - position) * firstControlPoint +
            3 * position * position * (1 - position) * secondControlPoint +
            position * position * position * 1.0
        
        return curve
    }
    
}

class ExponentialDecayEvaluator : Evaluate {

    let coeff:Double
    let offset:Double
    let scale:Double

    init(coeff:Double) {
        self.coeff = coeff
        self.offset = exp(-coeff);
        self.scale = 1.0 / (1.0 - offset);
    }

    func evaluateAt(position:Double) -> Double {
        return 1.0 - scale * (exp(position * -coeff) - offset)
    }

}


class SecondOrderResponseEvaluator : Evaluate {

    let zeta:Double
    let omega:Double

    init(omega:Double, zeta:Double) {
        self.omega = omega
        self.zeta = zeta
    }

    func evaluateAt(position:Double) -> Double {
        let beta = sqrt(1 - zeta * zeta);
        let phi = atan(beta / zeta);
        let result = 1.0 + -1.0 / beta * exp(-zeta * omega * position) * sin(beta * omega * position + phi);
        return result
    }

}


class ReverseQuadraticEvaluator : Evaluate {

    let a:Double
    let b:Double

    init(a:Double, b:Double) {
        self.a = a
        self.b = b
    }

    func evaluateAt(position:Double) ->  Double {
        return a * position * (position - b)
    }
    
}
