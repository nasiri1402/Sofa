//
//  MyDataRouter.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import SwiftUI

enum MyDataRoute {
    case name, age, gender, country
}

final class MyDataRouter: HashableRouter {

    // MARK: - Private Properties

    private let navigator: Navigator

    // MARK: - Inits

    init(navigator: Navigator) {
        self.navigator = navigator
    }

    // MARK: - Public Methods

    func route(to route: MyDataRoute) {
        let router: any Routable = switch route {
        case .name: NameRouter(navigator: navigator)
        case .age: AgeRouter(navigator: navigator)
        case .gender: GenderRouter(navigator: navigator)
        case .country: CountryRouter(navigator: navigator)
        }
        navigator.push(router)
    }

    func back() {
        navigator.pop()
    }
}

// MARK: - ViewFactory

extension MyDataRouter: ViewFactory {
    func makeView() -> AnyView {
        let viewModel = MyDataViewModel(router: self, dataStorage: ServiceLayer.dataStorage)
        let view = MyDataView(viewModel: viewModel)
        return AnyView(view)
    }
}
