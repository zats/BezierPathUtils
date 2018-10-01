//
//  BezierPathUtils.swift
//  BezierPathUtils
//
//  Created by Sash Zats on 9/30/18.
//  Copyright © 2018 Sash Zats. All rights reserved.
//

import CoreGraphics

public enum PathElement {
  case moveTo(CGPoint)
  case line(CGPoint, CGPoint)
  case quadraticCurve(QuadraticCurve)
  case cubicCurve(CubicCurve)
}

public struct QuadraticCurve {
  public let p1: CGPoint
  public let p2: CGPoint
  public let anchor: CGPoint
}

public struct CubicCurve {
  public let p1: CGPoint
  public let p2: CGPoint
  public let anchor1: CGPoint
  public let anchor2: CGPoint
}

public extension CGPath {
  func pathElements() -> [CGPathElement] {
    var elements: [CGPathElement] = []
    applyWithBlock { (element) in
      elements.append(element.pointee)
    }
    return elements
  }

}

public extension CGPath {
  public func elements() -> [PathElement] {
    let elements = self.pathElements()

    var results: [PathElement] = []
    for (i, elem) in elements.enumerated() {
      var pathElements: PathElement?
      switch i {
      case 0:
        // first element
        pathElements = pathElement(from: elem, nil)
      case elements.count - 1:
        // last element
        pathElements = pathElement(from: elem, elements[0])
      default:
        // all other elements
        pathElements = pathElement(from: elem, elements[i-1])
      }
      if let pathElements = pathElements {
        results.append(pathElements)
      } else {
        assertionFailure("Failed to convert path element: \(elem) @ \(i)")
      }
    }

    return results
  }

  private func pathElement(from e1: CGPathElement, _ e2: CGPathElement?) -> PathElement? {
    switch e1.type {
    case .moveToPoint:
      // ignore e1
      assert(e2 == nil)
      return .moveTo(e1.points[0])

    case .addLineToPoint:
      guard let e2 = e2 else {
        assertionFailure()
        return nil
      }
      return .line(e2.points[0], e1.points[0])

    case .addQuadCurveToPoint:
      guard let e2 = e2 else {
        assertionFailure()
        return nil
      }
      return .quadraticCurve(QuadraticCurve(p1: e1.points[0],
                                            p2: e2.points[0],
                                            anchor: e1.points[1]))
    case .addCurveToPoint:
      guard let e2 = e2 else {
        assertionFailure()
        return nil
      }
      return .cubicCurve(CubicCurve(p1: e1.points[0],
                                    p2: e2.points[0],
                                    anchor1: e1.points[1],
                                    anchor2: e1.points[2]))
    case .closeSubpath:
      guard let e2 = e2 else {
        assertionFailure()
        return nil
      }
      fatalError("Not implemented")
    }
  }
}
