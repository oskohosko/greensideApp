//
//  ShotAnnotationView.swift
//  Greenside
//
//  Created by Oskar Hosken on 15/5/2025.
//

import MapKit

final class ShotAnnotationView: MKAnnotationView {
  static let reuseID = "ShotAnnotationView"

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

    image = UIImage(
      systemName: "location.circle.fill",
      withConfiguration: UIImage.SymbolConfiguration(
        pointSize: 14,
        weight: .regular
      )
    )
    tintColor = .systemBlue
    canShowCallout = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
