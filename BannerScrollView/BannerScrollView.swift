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
 
        self.bannerScrollView.banners = [
            Course(id: 0, name: "扬琴艺术", photo: photo1),
            Course(id: 1, name: "演奏技巧", photo: photo2)
        ]
    }
 
}
```
*/

class BannerScrollView: UIView, UIScrollViewDelegate {
    
    // MARK: Public
    
    var banners = [BannerType]() { didSet { reloadData() } }
    
    var didSelectBanner: (BannerType -> Void)?
    
    // MARK: Properties
    
    private var currentIndex = 0
    
    private var currentBanner: BannerType? {
        if banners.isEmpty { return nil }
        let index = currentIndex % banners.count
        return banners[index]
    }
    
    private var realBanners: [BannerType] {
        
        if self.banners.count < 2 {
            return self.banners
        }
        
        var banners = [self.banners.last!] + self.banners
        banners += [self.banners.first!]
        return banners
    }
    
    private var realIndex: Int {
        get {
            if self.banners.count < 2 {
                return currentIndex
            }
            return currentIndex + 1
        }
        set {
            if self.banners.count < 2 {
                currentIndex = 0
            }
            currentIndex = newValue - 1
        }
    }
    
    private var scrollView: UIScrollView! {
        guard let scrollView = viewWithTag(1) as? UIScrollView else { return nil }
        if scrollView.delegate == nil {
            scrollView.delegate = self
        }
        return scrollView
    }
    
    private var contentView: UIView! {
        return viewWithTag(5)
    }
    
    private var bottomMaskView: UIView! {
        return viewWithTag(2)
    }
    
    private var titleLabel: UILabel! {
        return viewWithTag(3) as? UILabel
    }
    
    private var pageControl: UIPageControl! {
        return viewWithTag(4) as? UIPageControl
    }
    
    private var contentWidth: CGFloat {
        get { return contentViewWidthConstraint.constant }
        set { contentViewWidthConstraint.constant = newValue }
    }
    
    private var contentViewWidthConstraint: NSLayoutConstraint! {
        return contentView.constraints.find({ $0.identifier == "width" })
    }
    
    // MARK: Update Size
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBannerFrames()
    }
    
    private func updateBannerFrames() {
        contentWidth = CGFloat(realBanners.count) * bounds.width
        for (index, imageView) in contentView.subviews.enumerate() {
            let origin = CGPoint(x: bounds.width * CGFloat(index), y: 0)
            imageView.frame = CGRect(origin: origin, size: bounds.size)
        }
    }
    
    // MARK: Update UI
    
    private func reloadData() {
        startTimer()
        reloadImageViews()
        updateWithCurrentIndex(0)
        pageControl.numberOfPages = banners.count
    }
    
    func reloadImageViews() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        for banner in realBanners {
            let imageView = UIImageView()
            imageView.userInteractionEnabled = true
            imageView.contentMode = .ScaleToFill
            imageView.sd_setImageWithURL(banner.bannerPhoto, placeholderImage: banner.bannerPlaceholderImage)
            let tapGesture = UITapGestureRecognizer(target: self, action: "imageTaped:")
            imageView.addGestureRecognizer(tapGesture)
            contentView.addSubview(imageView)
        }
    }
    
    private func updateWithCurrentIndex(index: Int, animated: Bool = false) {
        currentIndex = index
        pageControl.currentPage = currentIndex
        titleLabel.text = currentBanner?.bannerTitle
        let offset = CGPoint(x: CGFloat(realIndex) * bounds.width, y: 0)
        scrollView.setContentOffset(offset, animated: animated)
    }
    
    // MARK: IBAction
    
    private func startTimer() {
        timer(5) { [weak self] time, _ in
            guard time == 0 else { return }
            self?.nextPage()
            self?.startTimer()
        }
    }
    
    private func nextPage() {
        let index = (currentIndex + 1) % banners.count
        let animated = !(index == 0)
        updateWithCurrentIndex(index, animated: animated)
    }
    
    func imageTaped(gesture: UIGestureRecognizer) {
        guard let currentBanner = currentBanner else { return }
        didSelectBanner?(currentBanner)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        realIndex = Int(scrollView.contentOffset.x / bounds.width)
        if currentIndex == banners.endIndex {
            updateWithCurrentIndex(currentIndex - banners.count)
        } else if currentIndex == -1 {
            updateWithCurrentIndex(currentIndex + banners.count)
        } else {
            updateWithCurrentIndex(currentIndex)
        }
    }

}


