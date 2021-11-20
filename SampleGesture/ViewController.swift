//
//  ViewController.swift
//  SampleGesture
//
//  Created by Massimiliano Bonafede on 18/11/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dragableImageView: DragableImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }


}

class DragableImageView: UIImageView {
    
    private var pinchGesture: UIPinchGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    var lastPointPinched: CGPoint!
    var lastPointPanned: CGPoint!
    var originalSize: CGSize!
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        originalSize = CGSize(width: bounds.width, height: bounds.height)
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(managePinch(_:)))
        addGestureRecognizer(pinchGesture)
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(managePan(_:)))
        addGestureRecognizer(panGesture)
        lastPointPinched = frame.origin
        lastPointPanned = frame.origin
    }
    
    @objc func managePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            let translation = sender.translation(in: self)
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            sender.setTranslation(.zero, in: self)
        case .ended:
            lastPointPanned.x = frame.origin.x
            lastPointPanned.y = frame.origin.y
            repositionAfterPan()
        default: break
        }
    }
    
    
    var pinchedView = UIView()
    var oldPoint: CGPoint = CGPoint(x: 0, y: 0)
    var oldSize: CGSize = CGSize(width: 0, height: 0)
    var size: CGSize = CGSize(width: 0, height: 0)
    
    @objc func managePinch(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began:
            oldSize = CGSize(width: frame.width, height: frame.height)
            oldPoint = CGPoint(x: frame.minX, y: frame.minY)
        case .changed:
            transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)

        case .ended:
            pinchedView = sender.view!
            lastPointPinched.x = frame.origin.x
            lastPointPinched.y = frame.origin.y
            lastPointPanned = lastPointPinched
            size = CGSize(width: frame.width, height: frame.height)
            repositionAfterPinch()
        default: break
        }
    }
    
    private func drawNewFrameForReposition(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    private func repositionAfterPinch() {
        if frame.width < bounds.width && size.width < originalSize.width {
            transform = .identity
            drawNewFrameForReposition(x: 0, y: 0, width: originalSize.width, height: originalSize.height)
            self.size = self.originalSize
            return
        }
        
//        if transform.isIdentity == false {
//            transform = .identity
//            frame = CGRect(x: lastPointPinched.x, y: lastPointPinched.y, width: size.width, height: size.height)
//            return
//        }
        transform = .identity
        var x: CGFloat = lastPointPinched.x
        var y: CGFloat = lastPointPinched.y
        
        
        
        if lastPointPinched.x > 0 && lastPointPinched.y > 0 {
            if size.width < originalSize.width {
                drawNewFrameForReposition(x: 0, y: 0, width: originalSize.width, height: originalSize.height)
                self.size = self.originalSize
                return
            } else {
                drawNewFrameForReposition(x: 0, y: 0, width: oldSize.width, height: oldSize.height)
                self.size = self.oldSize
                return
            }
        }
        
        if lastPointPinched.x > 0 && lastPointPinched.y < 0 {
            if size.width < originalSize.width {
                drawNewFrameForReposition(x: 0, y: 0, width: originalSize.width, height: originalSize.height)
                self.size = self.originalSize
                return
            } else {
                drawNewFrameForReposition(x: oldPoint.x, y: oldPoint.y, width: oldSize.width, height: oldSize.height)
                self.size = self.oldSize
                return
            }
        }
        
        let heightDiff = -(frame.height - size.height)
        let widthDiff = -(frame.width - oldSize.width)
        #warning("Gestire questo caso")
        if lastPointPinched.x < 0 && lastPointPinched.y < 0 && frame.maxX < originalSize.width {
            if size.width < originalSize.width {
                drawNewFrameForReposition(x: 0, y: 0, width: originalSize.width, height: originalSize.height)
                self.size = self.originalSize
                return
            } else {
                drawNewFrameForReposition(x: oldPoint.x, y: oldPoint.y, width: oldSize.width, height: oldSize.height)
                self.size = self.oldSize
                return
            }
        }
        
        if lastPointPinched.x < 0 && lastPointPinched.y > 0 {
            if size.width < originalSize.width {
                drawNewFrameForReposition(x: 0, y: 0, width: originalSize.width, height: originalSize.height)
                self.size = self.originalSize
                return
            } else {
                drawNewFrameForReposition(x: oldPoint.x, y: oldPoint.y, width: oldSize.width, height: oldSize.height)
                self.size = self.oldSize
                return
            }
        }
        
        frame = CGRect(x: lastPointPinched.x, y: lastPointPinched.y, width: size.width, height: size.height)
    }
    
    func repositionAfterPan() {
        if frame.width == bounds.width && size.width == 0 && size.height == 0 {
            print("0")
            drawNewFrameForReposition(x: 0, y: 0, width: frame.width, height: frame.height)
            return
        }
        
        if transform.isIdentity == false {
            transform = .identity
            frame = CGRect(x: lastPointPanned.x, y: lastPointPanned.y, width: size.width, height: size.height)
            return
        }
        
        var x: CGFloat = frame.minX
        var y: CGFloat = frame.minY
        
        if frame.minX > 0 {
            if frame.minX > 0 && frame.maxX > originalSize.width {
                x = 0
            } else {
                let widthDiff = -(frame.width - originalSize.width)
                x = widthDiff
            }
        } else if frame.minX < 0 {
            let widthDiff = -(frame.width - originalSize.width)
            if frame.minX < widthDiff {
                x = widthDiff
            }
        }
        
        if frame.minY > 0 {
            y = 0
        } else if frame.minY < 0 {
            let heightDiff = -(frame.height - originalSize.height)
            if frame.minY < heightDiff {
                y = heightDiff
            }
        }
        
        drawNewFrameForReposition(x: x, y: y, width: size.width, height: size.height)
    }
}


















//private func reposition() {
//    var targetX: CGFloat = 0
//    var targetY: CGFloat = 0
//
//    if frame.width == bounds.width && size.width == 0 && size.height == 0 {
//        print("0")
//        targetX = 0
//        targetY = 0
//        frame = CGRect(x: targetX, y: targetY, width: frame.width, height: frame.height)
//        return
//    } else {
//        transform = .identity
//        if frame.minX > 0 && frame.minY > 0 {
//            let diffX = frame.width - originalSize.width
//            let diffY = frame.height - originalSize.height
//            if frame.minX > diffX && frame.minY > diffY {
//                print("1")
//                frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//                return
//            } else {
//                print("1-1")
//                frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//                return
//            }
//
//        } else if frame.minX > 0 && frame.minY < 0 && frame.maxY < bounds.maxY {
//            print("2-1")
//            let diffY: CGFloat = -(frame.height - originalSize.height)
//            if frame.minX > 0 && frame.minY < diffY {
//                print("2-2")
//                targetX = 0
//                targetY -= (frame.height - originalSize.height)
//                frame = CGRect(x: targetX, y: targetY, width: size.width, height: size.height)
//                return
//            } else if frame.minX > 0 && frame.minY > diffY {
//                print("2-3")
//                frame = CGRect(x: 0, y: frame.minY, width: size.width, height: size.height)
//                return
//            } else if frame.minY == -(frame.height - originalSize.height) {
//                print("2-4")
//                frame = CGRect(x: 0, y: frame.minY, width: size.width, height: size.height)
//                return
//            } else {
//                print("2-5")
//                frame = CGRect(x: frame.minX, y: frame.minY, width: size.width, height: size.height)
//                return
//            }
//        } else if frame.minX < 0 && frame.minY < 0 && frame.maxX < bounds.maxX && frame.maxY < bounds.height {
//            print("3")
//           // if frame.maxX < bounds.maxX && frame.maxY < bounds.height {
//                print("3-1")
//                let diffX: CGFloat = -(frame.width - originalSize.width)
//                let diffY: CGFloat = -(frame.height - originalSize.height)
//                if frame.minX < diffX && frame.minY < diffY {
//                    print("3-2")
//                    targetX -= (frame.width - originalSize.width)
//                    targetY -= (frame.height - originalSize.height)
//                    frame = CGRect(x: targetX, y: targetY, width: size.width, height: size.height)
//                    return
//                } else if frame.minX < diffX && frame.minY < abs(diffY) {
//                    print("3-3")
//                    targetX -= (frame.width - originalSize.width)
//                    frame = CGRect(x: targetX, y: frame.minY, width: size.width, height: size.height)
//                    return
//                } else if frame.minX > diffX && frame.minY < diffY {
//                    print("3-4")
//                    frame = CGRect(x: frame.minX, y: diffY, width: size.width, height: size.height)
//                    return
//                } else if frame.minX == -(frame.width - originalSize.width) && frame.minY < -(frame.height - originalSize.height) {
//                    print("3-5")
//                    frame = CGRect(x: frame.minX, y: diffY, width: size.width, height: size.height)
//                    return
//                } else {
//                    print("3-6")
//                    frame = CGRect(x: frame.minX, y: frame.minY, width: size.width, height: size.height)
//                    return
//                }
//           // }
//        } else if frame.minX < 0 && frame.minY > 0 && frame.maxX < bounds.maxX && frame.maxY > bounds.maxY {
//            print("4")
//            if frame.maxX < bounds.maxX && frame.maxY > bounds.maxY {
//                print("4-1")
//                let diffX: CGFloat = -(frame.width - originalSize.width)
//                let diffY: CGFloat = (frame.height - originalSize.height)
//                if frame.minX < diffX && diffY > 0 {
//                    print("4-2")
//                    targetX -= (frame.width - originalSize.width)
//                    targetY = 0
//                    frame = CGRect(x: targetX, y: targetY, width: size.width, height: size.height)
//                    return
//                } else if frame.minX > diffX && diffY > 0 {
//                    print("4-3")
//                    frame = CGRect(x: frame.minX, y: 0, width: size.width, height: size.height)
//                    return
//                } else if frame.minX == -(frame.width - originalSize.width) && frame.minY > 0 {
//                    print("4-4")
//                    frame = CGRect(x: frame.minX, y: 0, width: size.width, height: size.height)
//                    return
//                } else if frame.minX < 0 && originalSize == size {
//                    print("4-5")
//                    frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//                    return
//                } else {
//                    print("4-6")
//                    frame = CGRect(x: frame.minX, y: frame.minY, width: size.width, height: size.height)
//                    return
//                }
//
//            } else {
//                print("4-6")
//                frame = CGRect(x: frame.minX, y: frame.minY, width: size.width, height: size.height)
//                return
//            }
//        } else {
//            print("5")
//            if frame.minX > 0 && frame.minY == 0 {
//                print("5-1")
//                frame = CGRect(x: 0, y: frame.minY, width: size.width, height: size.height)
//                return
//            } else if frame.minX == 0 && frame.minY > 0 {
//                print("5-2")
//                frame = CGRect(x: frame.minX, y: 0, width: size.width, height: size.height)
//                return
//            } else if frame.minX < -(frame.width - originalSize.width) && frame.minY == 0 {
//                print("5-3")
//                frame = CGRect(x: -(frame.width - originalSize.width), y: frame.minY, width: size.width, height: size.height)
//                return
//            } else if frame.minX == 0 && frame.minY < 0 {
//                print("5-4")
//                frame = CGRect(x: frame.minX, y: -(frame.height - originalSize.height), width: size.width, height: size.height)
//                return
//            } else {
//                print("5-5")
//                frame = CGRect(x: lastPointPinched.x, y: lastPointPinched.y, width: size.width, height: size.height)
//                return
//            }
//
//
//        }
//    }
//
////        transform = .identity
//  //  frame = CGRect(x: frame.minX, y: frame.minY, width: pinchedView.frame.width, height: pinchedView.frame.height)
//
//}
