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

    /// Used for comparing frame after transformation with the original frame
    var originalFrame: CGRect {
        superview?.frame ?? CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    /// Used for track frame changed on began state for UIPinchGestureRecognizer
    var framePinchBegan = CGRect(x: 0, y: 0, width: 0, height: 0)
    /// Used for track frame changed on ended state for UIPinchGestureRecognizer
    var framePinchEnded = CGRect(x: 0, y: 0, width: 0, height: 0)
    /// Used for track frame changed on enede state for UIPanGestureRecognizer
    var framePanEnded = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(managePinch(_:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(managePan(_:))))
    }

    @objc func managePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            let translation = sender.translation(in: self)
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            sender.setTranslation(.zero, in: self)
        case .ended:
            framePanEnded = frame
            repositionAfterPan()
        default: break
        }
    }
    
    
    private func repositionAfterPan() {
        
        // Caso in cui usiamo il pan gesture senza aver modificato il frame
        if frame.width == originalFrame.width {
            drawNewFrameForReposition(x: 0, y: 0, width: frame.width, height: frame.height)
            return
        }
        
        // Premessa: il frame viene ignorato se vengono compiute trasformazioni su di esso e quindi dopo risulta impossibile andare a stabilire correttamente i punti degli assi
        // Quindi nel caso in cui il frame risultasse ancora non conforme con `identity` lo riportiamo allo stato di `identity` e andiamo a settare il nuovo frame con le misure che abbiamo dopo il panGesture
        if transform.isIdentity == false {
            transform = .identity
            frame = framePanEnded
        }
        
        var x = frame.minX
        var y = frame.minY
        
        // Calcolo della cordinata X nel caso in cui è minore o maggiore di zero
        // Nel caso in cui è minore andiamo a calcolarci la differenza di larghezza tra il frame attuale e quello originale e gli aggiungiamo il valore corrente della X cosi nel caso `rightSideSurplus` è maggiore sappiamo che c'è il frame risulta sbordare dalla parte destra e quindi impostiamo la X con il valore attuale mentre se fosse minore assegniamo alla X la differenza in negativo del frame dopo il pinched con il frame originale facendo combaciare il lato destro del nuovo frame con quello originale.
        if x > 0 {
            x = 0
        } else if x < 0 {
            let rightSideSurplus = frame.minX + (frame.width - originalFrame.width)
            if rightSideSurplus > 0 {
                x = frame.minX
            } else {
                x = -(framePinchEnded.width - originalFrame.width)
            }
        }
        
        // Stesso calcolo viene applicato per la Y ma la differenza `bottomSideSurplus` viene calcolata sull'altezza
        if y > 0 {
            y = 0
        } else if y < 0 {
            let bottomSideSurplus = frame.minY + (frame.height - originalFrame.height)
            if bottomSideSurplus > 0 {
                y = frame.minY
            } else {
                y = -(framePinchEnded.height - originalFrame.height)
            }
        }
        
        // Usiamo come width e height il valore che ci ritorna dallo stato ended del pich
        drawNewFrameForReposition(x: x, y: y, width: framePinchEnded.width, height: framePinchEnded.height)
    }
    
    
    
    @objc func managePinch(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began:
            framePinchBegan = frame
        case .changed:
            transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)

        case .ended:
            framePinchEnded = frame
            repositionAfterPinch()
        default: break
        }
    }
    
    private func repositionAfterPinch() {
        // Caso in cui dopo il pinch il frame risulti più piccolo delle dimensioni originali è quindi lo ripristiniamo
        if frame.width < originalFrame.width {
            transform = .identity
            drawNewFrameForReposition(x: 0, y: 0, width: originalFrame.width, height: originalFrame.height)
            return
        }
        
        transform = .identity
        frame = framePinchEnded
        var x = frame.minX
        var y = frame.minY
        
        // Se origin è nel quadrante basso destro
        if x > 0  && y > 0 {
            framePinchEnded = framePinchBegan
            drawNewFrameForReposition(x: 0, y: 0, width: framePinchBegan.width, height: framePinchBegan.height)
            return
        }
        
        // Se origin è nel quadrante alto destro
        if x > 0  && y < 0 {
            x = framePinchBegan.minX
            y = framePinchBegan.minY
            framePinchEnded = framePinchBegan
            drawNewFrameForReposition(x: x, y: y, width: framePinchBegan.width, height: framePinchBegan.height)
            return
        }
        
        // Se origin è nel quadrante alto sinistro
        if x < 0  && y < 0 {
            let bottomSideSurplus = frame.minY + (frame.height - originalFrame.height)
            let rightSideSurplus = frame.minX + (frame.width - originalFrame.width)
            
            if bottomSideSurplus < 0 && rightSideSurplus < 0 {
                x = framePinchBegan.minX
                y = framePinchBegan.minY
                framePinchEnded = framePinchBegan
                drawNewFrameForReposition(x: x, y: y, width: framePinchBegan.width, height: framePinchBegan.height)
                return
            } else {
                drawNewFrameForReposition(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
                return
            }
        }
        
        // Se origin è nel quadrante basso sinistro
        if x < 0  && y > 0{
            x = framePinchBegan.minX
            y = framePinchBegan.minY
            framePinchEnded = framePinchBegan
            drawNewFrameForReposition(x: x, y: y, width: framePinchBegan.width, height: framePinchBegan.height)
            return
        }
    }
    
    private func drawNewFrameForReposition(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.frame = CGRect(x: x, y: y, width: width, height: height)
        }
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
