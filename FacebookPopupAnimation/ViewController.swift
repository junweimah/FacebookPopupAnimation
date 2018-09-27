//
//  ViewController.swift
//  FacebookPopupAnimation
//
//  Created by Tandem on 11/07/2018.
//  Copyright © 2018 Tandem. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var selectedIcons = 0
    
    let ivBackground: UIImageView = {
       let imageview = UIImageView(image: #imageLiteral(resourceName: "fb_core_data_bg"))
        return imageview
    }()
    
    let iconsContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        //configurations
        //change the size here
        let iconHeight: CGFloat = 38
        let padding: CGFloat = 6
        
        //above this is the typical way we will do to have all the views with different color
//        let redView = UIView()
//        redView.backgroundColor = .red
//        let blueView = UIView()
//        blueView.backgroundColor = .blue
//        let yellowView = UIView()
//        yellowView.backgroundColor = .yellow
//        let grayView = UIView()
//        grayView.backgroundColor = .gray
//
//        let arrangedSubviews = [redView,blueView,yellowView,grayView]
        
        let images = [#imageLiteral(resourceName: "blue_like"),#imageLiteral(resourceName: "red_heart"),#imageLiteral(resourceName: "surprised"),#imageLiteral(resourceName: "cry_laugh"),#imageLiteral(resourceName: "cry"),#imageLiteral(resourceName: "angry")]

        //below is the more advance way
        let arrangedSubviews = images.map({ (image) -> UIView in
            let iv = UIImageView(image: image)
            iv.layer.cornerRadius = iconHeight / 2
            iv.isUserInteractionEnabled = true
            return iv
        })
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fillEqually
        
        stackView.spacing = padding
        stackView.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        containerView.addSubview(stackView)
        
        let numberOfIcons = CGFloat(arrangedSubviews.count)
        let width = (iconHeight * numberOfIcons) + ((numberOfIcons + 1) * padding)
        
        containerView.frame = CGRect(x: 0, y: 0, width: width, height: iconHeight + 2 * padding)
        containerView.layer.cornerRadius = containerView.frame.height / 2
        
        //shadow
        containerView.layer.shadowColor = UIColor(white: 0.4, alpha: 0.4).cgColor
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4) //make the shadow underneath the containerview
        
        stackView.frame = containerView.frame
        
        return containerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(ivBackground)
        ivBackground.frame = view.frame
        
        setupLongPressGesture()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupLongPressGesture(){
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress)))
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer){
        
        switch gesture.state {
        case .began:
            handleGestureBegan(gesture: gesture)
        case .ended:
            //clean up the animation, bring down all the view once let go of finger
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                let stackView = self.iconsContainerView.subviews.first //since we know the hierachy, we know the first child of the iconscontainerview is the stack view
                stackView?.subviews.forEach({ (imageView) in
                    imageView.transform = .identity // for each of the image view in the stack view, animate them down
                })
                
                self.iconsContainerView.transform = self.iconsContainerView.transform.translatedBy(x: 0, y: 50) //bring the view back down
                self.iconsContainerView.alpha = 0
            }) { (_) in //_ because we dont need it
                self.iconsContainerView.removeFromSuperview()
            }
        case .changed: //when user long press, and move finger
            handleGestureChanged(gesture: gesture)
        default:
            break
        }
    }
    
    fileprivate func handleGestureChanged(gesture: UILongPressGestureRecognizer) {
        let pressLocation = gesture.location(in: self.iconsContainerView) //using iconsContainerView because we are capturing the point we click calculated relative to the iconsContainerView, so the top left corner of the press location of the iconsContainerView will be 0,0
        
        let fixYLocation = CGPoint(x: pressLocation.x, y: self.iconsContainerView.frame.height / 2)
        
//        print("fixYLocation : " ,fixYLocation)
        
        let hitTestView = iconsContainerView.hitTest(fixYLocation, with: nil)//hitTest will get the the lowest desendant in the view hierachy, so the lowest here is the image view
        
        if hitTestView is UIImageView {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                let stackView = self.iconsContainerView.subviews.first //since we know the hierachy, we know the first child of the iconscontainerview is the stack view
                stackView?.subviews.forEach({ (imageView) in
                    imageView.transform = .identity // for each of the image view in the stack view, animate them down
                })
                
                hitTestView?.transform = CGAffineTransform(translationX: 0, y: -50) //this will move the image view up
                let thisViewCenterX: CGFloat! = hitTestView?.center.x //this view selected (that goes up), center x
                
                // int to remove decimal, floor to remove all decimal without rounding, / 45 is (width / number of item), + 1 because start from 0
                let selectedIcon = Int((floor(thisViewCenterX / 45) + 1))
                
//                print("this view center x : " ,thisViewCenterX)
                print("selected icon : \(selectedIcon)")
                
            })
        }
        
    }
    
    fileprivate func handleGestureBegan(gesture: UILongPressGestureRecognizer) {
        view.addSubview(iconsContainerView)
        
        let pressedLocation = gesture.location(in: self.view)
        print("long pressedLocation ",pressedLocation)
        
        //trasnformation of rex box
        let centerX = (view.frame.width - iconsContainerView.frame.width) / 2
        iconsContainerView.transform = CGAffineTransform(translationX: centerX, y: pressedLocation.y)
        
        //set alpha to 0 first
        iconsContainerView.alpha = 0
        
        //animate
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            //animate the view to fade in
            self.iconsContainerView.alpha = 1
            
            //animate the view upwards
            self.iconsContainerView.transform = CGAffineTransform(translationX: centerX, y: pressedLocation.y - self.iconsContainerView.frame.height)
        })
    }

}

