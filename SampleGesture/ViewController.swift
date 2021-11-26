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
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var doubleTapGestureRecognizer: UITapGestureRecognizer!
    private var canStartPanning: Bool = false
    private var needResizeToOrigin: Bool = false {
        didSet {
            if needResizeToOrigin {
                canStartPanning = false
                UIView.animate(withDuration: 0.2) {
                    self.transform = .identity
                    self.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Enable user interaction on DragableImageView
        isUserInteractionEnabled = true
        // Add PinchGesture to DragableImageView
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(managePinch(_:))))
        // Add PanGesture to DragableImageView
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(managePan(_:))))
        // Add TapGesture on DragableImageView and set the numbers of tap requires
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(manageTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
        // Add DoubleTapGesture on DragableImageView and set the numbers of tap requires
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(manageDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    
    @objc private func manageTap(_ sender: UITapGestureRecognizer) {}
    
    @objc private func manageDoubleTap(_ sender: UITapGestureRecognizer) {
        guard canStartPanning == true, let container = superview else { return }
        
        switch sender.state {
        case .ended:
            needResizeToOrigin = true
        default: break
        }
    }
    
    @objc private func managePan(_ sender: UIPanGestureRecognizer) {
        guard canStartPanning == true else { return }
        
        switch sender.state {
        case .changed:
            let scale = (frame.width / superview!.bounds.width)
            var translation = sender.translation(in: self)
            translation.x *= scale
            translation.y *= scale
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self)
        case .ended:
            autoReposition()
        default: break
        }
    }

    @objc func managePinch(_ sender: UIPinchGestureRecognizer) {
        guard let container = superview else { return }
        
        switch sender.state {
        case .changed:
            transform = transform.scaledBy(x: sender.scale, y: sender.scale)
        case .ended:
            canStartPanning = true
            if frame.width < superview!.bounds.width {
                needResizeToOrigin = true
            } else {
                autoReposition()
            }
        default: break
        }
        
        sender.scale = 1
    }
    
    private func autoReposition() {
        var centerX = center.x
        var centerY = center.y
        let width = bounds.width
        let height = bounds.height
        let rangeOfWidth = 0 ... width
        let rangeOfHeight = 0 ... height
        
        if frame.minX > width || frame.maxY < 0 || frame.maxX < 0 || frame.minY > height {
            needResizeToOrigin = true
            return
        }
        
        if rangeOfWidth.contains(frame.minX) {
            centerX -= frame.minX
        }

        if rangeOfHeight.contains(frame.minY) {
            centerY -= frame.minY
        }

        if rangeOfWidth.contains(frame.maxX) {
            centerX += width - frame.maxX
        }

        if rangeOfHeight.contains(frame.maxY) {
            centerY += height - frame.maxY
        }

        UIView.animate(withDuration: 0.2) {
            self.center = CGPoint(x: centerX, y: centerY)
        }
    }
}
