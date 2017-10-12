//
//  GraphView.swift
//  Calculator
//
//  Created by Bao Nguyen on 10/2/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import UIKit

protocol DataSource {
    func getY(fromX x: CGFloat) -> CGFloat?
    
}

@IBDesignable
class GraphView : UIView {
    
    @IBInspectable
    var scale: CGFloat = 50 { didSet {setNeedsDisplay() } }
    
    var origin: CGPoint! { didSet {setNeedsDisplay() } } // graph's origin
    
    @IBInspectable
    var color: UIColor = UIColor.blue { didSet {setNeedsDisplay() } }
    
    @IBInspectable
    var lineWidth: CGFloat = 1.0 { didSet {setNeedsDisplay() } }
    
    var dataSource: DataSource?
    
    override func draw(_ rect: CGRect) {
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        axes.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
        color.set()
        functionPath().stroke()
    }
    
    @objc
    func moveOrigin(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            origin = tapRecognizer.location(in: self)
        }
    }
    
    @objc
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    @objc
    func translate(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .ended:
            let translation = panRecognizer.translation(in: self)
            origin.x += translation.x
            origin.y += translation.y
            panRecognizer.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }
    
    // Private fields
    private let axes = AxesDrawer(color: UIColor.blue)
    
    private func functionPath() -> UIBezierPath {
        let path = UIBezierPath()
        var point = CGPoint()
        var pathIsEmpty = true
        let width = Int(bounds.size.width * scale) // in pixel instead of in point
        
        for pixel in 0...width {
            point.x = CGFloat(pixel) / scale
            if let data = dataSource,
                let y = data.getY(fromX: (point.x - origin.x) / scale){
                
                if !y.isZero && !y.isNormal {
                    pathIsEmpty = true;
                    continue
                }
                
                point.y = origin.y - y * scale

                if pathIsEmpty {
                    path.move(to: point)
                    pathIsEmpty = false
                } else {
                    path.addLine(to: point)
                }
            }
        }
        path.lineWidth = lineWidth
        return path
    }
    
    
}
