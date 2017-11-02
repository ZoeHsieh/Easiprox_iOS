//
//  UIStoryboard.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/8.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation
import UIKit


protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension UIStoryboard {
    enum Storyboard : String {
        case Main
        case Intro
    }
    
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
}


extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIStoryboard {
    func instantiateViewController<T: UIViewController>() -> T where T: StoryboardIdentifiable {
        let optionalViewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier)
        
        guard let viewController = optionalViewController as? T  else {
            fatalError("Couldn’t instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        
        return viewController
    }
}

