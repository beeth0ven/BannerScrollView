//
//  ViewController.swift
//  BannerScrollView
//
//  Created by luojie on 16/3/18.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var bannerScrollView: BannerScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bannerScrollView.didSelectBanner = { banner in
            let course = banner as! Course
            print("pushCourseViewController with id: \(course.id)")
        }
        
        Queue.Main.executeAfter(seconds: 2) {
            
            let banners: [BannerType] = [
                Course(id: 0, name: "扬琴艺术", photo: photo1),
                Course(id: 1, name: "演奏技巧", photo: photo2)
            ]
            
            self.bannerScrollView.banners = banners
        }
    }
    
}
