//
//  BannerScrollView.swift
//  BannerScrollView
//
//  Created by luojie on 16/3/18.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
/**
 The type should used as banner should comform this protocol.
 For exmaple：
 ```swift
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
 
 ```
 Course can be represented as banner, course.name shows as bannerTitle, and course.name shows as bannerPhoto.
 */
protocol BannerType {
    var bannerTitle: String { get }
    var bannerPhoto: NSURL { get }
    var bannerPlaceholderImage: UIImage? { get }
}

extension BannerType {
    var bannerPlaceholderImage: UIImage? { return nil }
}

/**
 BannerScrollView wrapped banners with easy to use api.
 Usage：
 You just need to drag BannerScrollView from BannerScrollView.storyboard.
 Then create a @IBOutlet with it, lastly give minimal configuration.
 ```swift
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
```
*/

class BannerScrollView: UIView, UIScrollViewDelegate {
    
    var banners: [BannerType]? { didSet { reloadData() } }
    
    var didSelectBanner: (BannerType -> Void)?
    
    private var currentIndex = 0 { didSet { updateUI() } }
    
    private var currentBanner: BannerType? {
        guard let banners = banners
            where currentIndex < banners.endIndex else { return nil }
        return banners[currentIndex]
    }
    
    private var bannersCount: Int {
        return banners?.count ?? 0
    }
    
    private var scrollView: UIScrollView {
        return viewWithTag(1) as! UIScrollView
    }
    
    private var contentView: UIView {
        return viewWithTag(5)!
    }
    
    private var bottomMaskView: UIView {
        return viewWithTag(2)!
    }
    
    private var titleLabel: UILabel {
        return viewWithTag(3) as! UILabel
    }
    
    private var pageControl: UIPageControl {
        return viewWithTag(4) as! UIPageControl
    }
    
    private var contentWidth: CGFloat {
        get { return contentViewWidthConstraint.constant }
        set { contentViewWidthConstraint.constant = newValue }
    }
    
    private var contentViewWidthConstraint: NSLayoutConstraint {
        return contentView.constraints.filter ({ $0.identifier == "width" }).first!
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if scrollView.delegate == nil {
            scrollView.delegate = self
        }
    }
     func imageTaped(gesture: UIGestureRecognizer) {
        guard let currentBanner = currentBanner else { return }
        didSelectBanner?(currentBanner)
    }
    
    private func startTimer() {
        timer(5) { [weak self] time, _ in
            guard time == 0 else { return }
            self?.nextPage()
            self?.startTimer()
        }
    }
    
    private func nextPage() {
        currentIndex = (currentIndex + 1) % bannersCount
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / bounds.width)
    }
    
    private func reloadData() {
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        contentWidth = CGFloat(bannersCount) * bounds.width
        pageControl.numberOfPages = bannersCount
        
        startTimer()
        
        guard let banners = banners else { return }
        
        for (index, banner) in banners.enumerate() {
            let x = CGFloat(index) * bounds.width
            let origin = CGPoint(x: x, y: 0)
            let imageView = UIImageView(frame: CGRect(origin: origin, size: bounds.size))
            imageView.userInteractionEnabled = true
            imageView.contentMode = .ScaleToFill
            imageView.sd_setImageWithURL(banner.bannerPhoto, placeholderImage: banner.bannerPlaceholderImage)
            let tapGesture = UITapGestureRecognizer(target: self, action: "imageTaped:")
            imageView.addGestureRecognizer(tapGesture)
            contentView.addSubview(imageView)
        }
        
        currentIndex = 0
    }
    
    private func updateUI() {
        pageControl.currentPage = currentIndex
        titleLabel.text = currentBanner?.bannerTitle
        let offset = CGPoint(x: CGFloat(currentIndex) * bounds.width, y: 0)
        scrollView.setContentOffset(offset, animated: currentIndex != 0)
    }
}


