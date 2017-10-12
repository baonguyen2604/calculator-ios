//
//  GraphViewController.swift
//  Calculator
//
//  Created by Bao Nguyen on 10/2/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, DataSource
{
    // public API
    func getY(fromX x: CGFloat) -> CGFloat? {
        let xInDouble = Double(x)
        let yInDouble = function?(xInDouble)
        return CGFloat(yInDouble ?? 0.0)
    }
    
    var function: ((_ x: Double) -> Double?)?

    // private section
    private let graphModel = GraphModel()
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            // delegate for DataSource protocol
            graphView.dataSource = self
            
            // pinch gesture recognizer and handler
            let pinchHandler = #selector(graphView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: pinchHandler)
            graphView.addGestureRecognizer(pinchRecognizer)
            
            // pan gesture recognizer and handler
            let panHandler = #selector(graphView.translate(byReactingTo:))
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: panHandler)
            graphView.addGestureRecognizer(panRecognizer)
            
            // tap gesture recognizer and handler
            let tapHandler = #selector(graphView.moveOrigin(byReactingTo:))
            let tapRecognizer = UITapGestureRecognizer(target: graphView, action: tapHandler)
            tapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapRecognizer)
        }
    }
}
