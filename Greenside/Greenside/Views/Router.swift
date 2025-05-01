//
//  Router.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import Combine

final class Router: ObservableObject {
  @Published var tab: Tab = .home
  @Published var deepLinkCourse: Course?
}
