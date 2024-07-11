//
//  SceneDelegate.swift
//  YoutubeAPI
//
//  Created by hansol on 2024/07/11.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let apiManager = APIManager()
        let mainVM = MainViewModel(manager: apiManager)
        let mainViewController = MainViewController(viewModel: mainVM)
        let navigationController = UINavigationController(rootViewController: mainViewController)
        
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
    }
    
    
}

