//
//  Course.swift
//  BannerScrollView
//
//  Created by luojie on 16/3/18.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import Foundation

struct Course {
    var id: Int
    var name: String
    var photo: NSURL
}

extension Course: BannerType {
    var bannerTitle: String {
        return name
    }
    
    var bannerPhoto: NSURL {
        return photo
    }
}

let photo1 = NSURL(string: "http://ovfun-10009040.image.myqcloud.com/upload/mavendemo/frontBanner/20151230/1451462972301417908.jpg")!
let photo2 = NSURL(string: "http://ovfun-10009040.image.myqcloud.com/upload/mavendemo/frontBanner/20151230/1451462965563082313.png")!

