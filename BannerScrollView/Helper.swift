//
//  Helper.swift
//  BannerScrollView
//
//  Created by luojie on 16/3/18.
//  Copyright © 2016年 LuoJie. All rights reserved.
//


import UIKit

extension Array {
    func find(@noescape predicate: (Element) -> Bool) -> Element? {
        return filter(predicate).first
    }
}

/**
 提供常用线程的简单访问方法. 用 Qos 代表线程对应的优先级。
 - Main:                 对应主线程
 - UserInteractive:      对应优先级高的线程
 - UserInitiated:        对应优先级中的线程
 - Utility:              对应优先级低的线程
 - Background:           对应后台的线程
 
 例如，异步下载图片可以这样写：
 ```swift
 Queue.UserInitiated.execute {
 
 let url = NSURL(string: "http://image.jpg")!
 let data = NSData(contentsOfURL: url)!
 let image = UIImage(data: data)
 
 Queue.Main.execute {
 imageView.image = image
 }
 }
 */

enum Queue: ExcutableQueue {
    case Main
    case UserInteractive
    case UserInitiated
    case Utility
    case Background
    
    var queue: dispatch_queue_t {
        switch self {
        case .Main:
            return dispatch_get_main_queue()
        case .UserInteractive:
            return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        case .UserInitiated:
            return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        case .Utility:
            return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        case .Background:
            return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        }
    }
}

/// 提供本 App 要使用的所有 SerialQueue，以下的 case 只是一个例子，可以根据需要修改
enum SerialQueue: String, ExcutableQueue {
    
    case DownLoadImage = "ovfun.Education.SerialQueue.DownLoadImage"
    case UpLoadFile = "ovfun.Education.SerialQueue.UpLoadFile"
    
    var queue: dispatch_queue_t {
        return dispatch_queue_create(rawValue, DISPATCH_QUEUE_SERIAL)
    }
}

/// 给 Queue 提供默认的执行能力
protocol ExcutableQueue {
    var queue: dispatch_queue_t { get }
}

extension ExcutableQueue {
    func execute(closure: () -> Void) {
        dispatch_async(queue, closure)
    }
    
    func executeAfter(seconds seconds: NSTimeInterval, closure: () -> Void) {
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        dispatch_after(delay, queue, closure)
    }
}

//倒计时方法
func timer(duration: NSTimeInterval, start: ((time : NSTimeInterval, fomatTime : String) -> ())?) -> dispatch_source_t{
    
    var d = duration
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
    dispatch_source_set_timer(timer, dispatch_walltime(nil, 0), 1*NSEC_PER_SEC, 0)
    
    dispatch_source_set_event_handler(timer, { () -> Void in
        
        if d <= 0{//结束倒计时
            
            dispatch_source_cancel(timer)
        }else{
            
            let hours = d/60/60
            let minutes = (d/60)%60
            let seconds = d%60
            
            d -= 1
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                start?(time: d, fomatTime: "\(hours):\(minutes):\(seconds)")
            })
        }
    })
    
    dispatch_resume(timer)
    return timer
}

extension UIImageView {
    func sd_setImageWithURL(url: NSURL, placeholderImage: UIImage?) {
        image = placeholderImage
        Queue.UserInitiated.execute {
            guard let
                data = NSData(contentsOfURL: url),
                image = UIImage(data: data) else { return }
            Queue.Main.execute {
                self.image = image
            }
        }
    }
}
