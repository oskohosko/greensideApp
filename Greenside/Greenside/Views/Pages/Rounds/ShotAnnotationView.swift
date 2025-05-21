//
//  ShotAnnotationView.swift
//  Greenside
//
//  Created by Oskar Hosken on 15/5/2025.
//

import MapKit

class ShotAnnotationView: MKAnnotationView {
  static let reuseID = "ShotAnnotationView"
  
  var size: Int = 10 {
    didSet {
      updateSize()
    }
  }

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

    setupAnnotation()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // This designs our shot annotation
  private func setupAnnotation() {
    updateSize()
    // Disabling callout
    self.canShowCallout = false
  }
  
  private func updateSize() {
    // Clearing any previous layers
    self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    // Creating a circular path
    let circlePath = UIBezierPath(
      ovalIn: CGRect(x: 0, y: 0, width: size, height: size)
    )

    // And for the border
    let borderLayer = CAShapeLayer()
    borderLayer.path = circlePath.cgPath
    borderLayer.fillColor = UIColor.blue400.cgColor
    borderLayer.strokeColor = UIColor.blue500.cgColor
    borderLayer.lineWidth = 2

    // Setting the frame
    self.frame = CGRect(x: 0, y: 0, width: size, height: size)

    // Adding the border layer to the view
    self.layer.addSublayer(borderLayer)

    // centering the view
    self.center = CGPoint(x: 0, y: -(size / 2))
  }
}
