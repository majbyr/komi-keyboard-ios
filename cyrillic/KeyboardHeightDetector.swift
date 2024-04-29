// KeyboardHeightDetector.swift

import UIKit

class Calculator {
    /**
     @return height of the view containing the keyboard buttons
     */
    static func getKeyboardHeight()->CGFloat{
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            //                          Portrait    Landscape
            return getWidth() < getHeight() ? 216 : 162
            
        } else{
            //                          Portrait    Landscape
            return getWidth() < getHeight() ? 265 : 353
            
        }
    }
    
    /**
     @return the height of the  toolbar
     */
    static func getToolbar() -> CGFloat{
        if UIDevice.current.userInterfaceIdiom == .phone {
            return getWidth() < getHeight() ? 45 : 38
            
        }
        //iPad
        return 55
    }
    
    static func getWidth() -> CGFloat{
        return UIScreen.main.bounds.width
    }
    static func getHeight() -> CGFloat{
        return UIScreen.main.bounds.height
    }
}
