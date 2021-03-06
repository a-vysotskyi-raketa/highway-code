//
//  CamerasBuilder.swift
//  HighwayCode
//
//  Created by Andrew Visotskyy on 21.07.2020.
//  Copyright © 2020 Gagnant. All rights reserved.
//

import UIKit

class CamerasBuilder {

    static func build() -> UIViewController {
        let presenter = CamerasPresenter(
            camerasService: Core.shared.cameras,
            locationAccessProvider: CoreLocationAccessStatusProvider()
        )
        let controller = CamerasViewController(presenter: presenter)
        presenter.view = controller
        let navigation = UINavigationController(rootViewController: controller)
        navigation.tabBarItem.title = Localized.Screen.Cameras.tabTitle
        navigation.tabBarItem.image = Asset.Images.speedCamera.image
        return navigation
    }

}
