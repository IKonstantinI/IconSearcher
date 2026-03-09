//
//  SceneDelegate.swift
//  IconSearcher
//
//  Created by Константин on 25.02.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let viewController = IconSearchAssembly.assemble()
        
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }

}

