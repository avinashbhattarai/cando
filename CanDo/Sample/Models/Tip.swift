//
//  Tip.swift
//  CanDo
//
//  Created by Svyat Zubyak on 9/14/16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import Foundation
import UIKit
class Tip {
    
    // MARK: Properties
    
    var title: String!
    var cover: String!
    var url: String!
    var image: UIImage?
    
    // MARK: Initialization
    
    init(title: String?, cover: String?, url: String?) {
        
        self.title = title ?? ""
        var newCover = cover ?? ""
        newCover = newCover.stringByReplacingOccurrencesOfString("\\", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        print(newCover)
        self.cover = newCover//"http://www.trakm8.com/wp-content/uploads/2013/11/customer_support_2.jpg"//
        var newUrl = url ?? ""
        newUrl = newUrl.stringByReplacingOccurrencesOfString("\\", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        print(newUrl)
        self.url = newUrl
       
    }
    
}
