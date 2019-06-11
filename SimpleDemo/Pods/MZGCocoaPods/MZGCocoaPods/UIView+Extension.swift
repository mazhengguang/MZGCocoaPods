//
//  UIView+Extension.swift
//  HealthStore
//
//  Created by 马争光 on 2018/9/6.
//  Copyright © 2018年 上海国民. All rights reserved.
//

import UIKit
import QuartzCore

extension UIView {
    
    func isShowingOnKeyWindow() -> Bool {
        let keyWindow: UIWindow? = UIApplication.shared.keyWindow
        // 把这个view在它的父控件中的frame(即默认的frame)转换成在window的frame
        let convertFrame: CGRect? = superview?.convert(frame, to: keyWindow)
        let windowBounds: CGRect? = keyWindow?.bounds
        // 判断这个控件是否在主窗口上（即该控件和keyWindow有没有交叉）
        let isOnWindow: Bool = convertFrame!.intersects(windowBounds!)
        // 再判断这个控件是否真正显示在窗口范围内（是否在窗口上，是否为隐藏，是否透明）
        let isShowingOnWindow: Bool? = (window == keyWindow) && !isHidden && (alpha > 0.01) && isOnWindow
        return isShowingOnWindow!
    }
    
    func setRoundedCorners(corners: UIRectCorner,radius: CGFloat) {
        let rect = self.bounds
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
}

// MARK: - 获取view所在的控制器
extension UIView {
    
    func getVC() -> UIViewController? {
        
        let n = next
        
        while n != nil {
            
            let controller = next?.next
            
            if (controller is UIViewController) {
                
                return controller as? UIViewController
            }
        }
        
        return nil
    }
    
}

// MARK: - 自适应AutoLayout
extension UIView {
    
    func yl_refreshFrame() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func yl_autoH() {
        setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
    }
    
    func yl_autoW() {
        setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
    }
}

// MARK: - UIView frame
extension UIView {
    
    // yl_x
    var yl_x : CGFloat {
        
        get {
            
            return frame.origin.x
        }
        
        set(newVal) {
            
            var tmpFrame : CGRect = frame
            tmpFrame.origin.x     = newVal
            frame                 = tmpFrame
        }
    }
    
    // yl_y
    var yl_y : CGFloat {
        
        get {
            
            return frame.origin.y
        }
        
        set(newVal) {
            
            var tmpFrame : CGRect = frame
            tmpFrame.origin.y     = newVal
            frame                 = tmpFrame
        }
    }
    
    // yl_height
    var yl_height : CGFloat {
        
        get {
            
            return frame.size.height
        }
        
        set(newVal) {
            
            var tmpFrame : CGRect = frame
            tmpFrame.size.height  = newVal
            frame                 = tmpFrame
        }
    }
    
    // yl_width
    var yl_width : CGFloat {
        
        get {
            
            return frame.size.width
        }
        
        set(newVal) {
            
            var tmpFrame : CGRect = frame
            tmpFrame.size.width   = newVal
            frame                 = tmpFrame
        }
    }
    
    // yl_left
    var yl_left : CGFloat {
        
        get {
            
            return yl_x
        }
        
        set(newVal) {
            
            yl_x = newVal
        }
    }
    
    // yl_right
    var yl_right : CGFloat {
        
        get {
            
            return yl_x + yl_width
        }
        
        set(newVal) {
            
            yl_x = newVal - yl_width
        }
    }
    
    // yl_top
    var yl_top : CGFloat {
        
        get {
            
            return yl_y
        }
        
        set(newVal) {
            
            yl_y = newVal
        }
    }
    
    // yl_bottom
    var yl_bottom : CGFloat {
        
        get {
            
            return yl_y + yl_height
        }
        
        set(newVal) {
            
            yl_y = newVal - yl_height
        }
    }
    
    var yl_centerX : CGFloat {
        
        get {
            
            return center.x
        }
        
        set(newVal) {
            
            center = CGPoint(x: newVal, y: center.y)
        }
    }
    
    var yl_centerY : CGFloat {
        
        get {
            
            return center.y
        }
        
        set(newVal) {
            
            center = CGPoint(x: center.x, y: newVal)
        }
    }
    
    var yl_middleX : CGFloat {
        
        get {
            
            return yl_width / 2
        }
    }
    
    var yl_middleY : CGFloat {
        
        get {
            
            return yl_height / 2
        }
    }
    
    var yl_middlePoint : CGPoint {
        
        get {
            
            return CGPoint(x: yl_middleX, y: yl_middleY)
        }
    }
    
}


extension UIView {
    
    //获取view所在VC
    func firstViewController() -> UIViewController? {
        
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let responder = view?.next {
                if responder.isKind(of: UIViewController.self){
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
}


extension UIView {
    
    private struct AssociatedKeys {
        static var descriptiveName = "AssociatedKeys.DescriptiveName.blurView"
    }
    
    private (set) var blurView: BlurView {
        get {
            if let blurView = objc_getAssociatedObject(
                self,
                &AssociatedKeys.descriptiveName
                ) as? BlurView {
                return blurView
            }
            self.blurView = BlurView(to: self)
            return self.blurView
        }
        set(blurView) {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.descriptiveName,
                blurView,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    class BlurView {
        
        private var superview: UIView
        private var blur: UIVisualEffectView?
        private var editing: Bool = false
        private (set) var blurContentView: UIView?
        private (set) var vibrancyContentView: UIView?
        
        var animationDuration: TimeInterval = 0.1
        
        /**
         * Blur style. After it is changed all subviews on
         * blurContentView & vibrancyContentView will be deleted.
         */
        var style: UIBlurEffect.Style = .light {
            didSet {
                guard oldValue != style,
                    !editing else { return }
                applyBlurEffect()
            }
        }
        /**
         * Alpha component of view. It can be changed freely.
         */
        var alpha: CGFloat = 0 {
            didSet {
                guard !editing else { return }
                if blur == nil {
                    applyBlurEffect()
                }
                let alpha = self.alpha
                UIView.animate(withDuration: animationDuration) {
                    self.blur?.alpha = alpha
                }
            }
        }
        
        init(to view: UIView) {
            self.superview = view
        }
        
        func setup(style: UIBlurEffect.Style, alpha: CGFloat) -> Self {
            self.editing = true
            
            self.style = style
            self.alpha = alpha
            
            self.editing = false
            
            return self
        }
        
        func enable(isHidden: Bool = false) {
            if blur == nil {
                applyBlurEffect()
            }
            
            self.blur?.isHidden = isHidden
        }
        
        private func applyBlurEffect() {
            blur?.removeFromSuperview()
            
            applyBlurEffect(
                style: style,
                blurAlpha: alpha
            )
        }
        
        private func applyBlurEffect(style: UIBlurEffect.Style,
                                     blurAlpha: CGFloat) {
            superview.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: style)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            blurEffectView.contentView.addSubview(vibrancyView)
            
            blurEffectView.alpha = blurAlpha
            
            superview.insertSubview(blurEffectView, at: 0)
            
            blurEffectView.addAlignedConstrains()
            vibrancyView.addAlignedConstrains()
            
            self.blur = blurEffectView
            self.blurContentView = blurEffectView.contentView
            self.vibrancyContentView = vibrancyView.contentView
        }
    }
    
    private func addAlignedConstrains() {
        translatesAutoresizingMaskIntoConstraints = false
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.top)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.leading)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.trailing)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.bottom)
    }
    
    private func addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute) {
        superview?.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: superview,
                attribute: attribute,
                multiplier: 1,
                constant: 0
            )
        )
    }
}

extension UIView {
    
    /// 类型集合
    private struct GMClosureContainer {
        var gm_tapClosure: ((UIView) -> ())
    }
    
    /// 转换的 key 集合
    private struct GMAssociatedKeys {
        static var gm_tapKey: GMClosureContainer?
    }
    
    /// 设置点击属性
    private var gm_tapContainer: GMClosureContainer? {
        get {
            if let newClosure = objc_getAssociatedObject(self, &GMAssociatedKeys.gm_tapKey) as? GMClosureContainer {
                return newClosure
            }
            return nil
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &GMAssociatedKeys.gm_tapKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// 点击事件回调闭包
    func gm_addTapClosure(_ closure: @escaping ((UIView) -> ())) {
        let blockContainer = GMClosureContainer(gm_tapClosure: closure)
        self.gm_tapContainer = blockContainer
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(gm_tapClick))
        self.addGestureRecognizer(tap)
    }
    
    /// 点击事件
    @objc private func gm_tapClick() {
        self.gm_tapContainer?.gm_tapClosure(self)
    }
    
    /// 添加手势点击事件
    func gm_addTarget(_ target: Any?, action: Selector?) {
        
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(tap)
    }
}

////设置圆角

extension UIView {
    
    /*** 设置uiview 的任意圆角 **/
    func setCornersWithView(_ view:UIView,corner:CGFloat) {
        let maskPath = UIBezierPath.init(roundedRect: view.bounds,
                                         byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.topRight],
                                         cornerRadii: CGSize(width: corner, height: corner))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
    }
    
    func setBorderWithView(_ view:UIView,top:Bool,left:Bool,bottom:Bool,right:Bool,width:CGFloat,color:UIColor) {
        
        if top  {
            let layer = CALayer()
            layer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: width)
            layer.backgroundColor = color.cgColor
            view.layer.addSublayer(layer)
        }
        
        if left  {
            let layer = CALayer()
            layer.frame = CGRect(x: 0, y: 0, width: width, height: view.frame.size.height)
            layer.backgroundColor = color.cgColor
            view.layer.addSublayer(layer)
        }
        
        if bottom   {
            let layer = CALayer()
            layer.frame = CGRect(x: 0, y: view.frame.size.height - width, width: width, height: width)
            layer.backgroundColor = color.cgColor
            view.layer.addSublayer(layer)
        }
        
        if right {
            let layer = CALayer()
            layer.frame = CGRect(x: view.frame.size.width - width, y: 0, width: width, height: view.frame.size.height)
            layer.backgroundColor = color.cgColor
            view.layer.addSublayer(layer)
        }
    }
    
    /// 部分圆角
    ///
    /// - Parameters:
    ///   - corners: 需要实现为圆角的角，可传入多个
    ///   - radii: 圆角半径
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    /**
     * 将一个UIView视图转为图片
     */
    public func gm_makeImage() -> UIImage? {
        let size = self.bounds.size
        
        /**
         * 第一个参数表示区域大小。
         第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。
         第三个参数就是屏幕密度了
         */
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
