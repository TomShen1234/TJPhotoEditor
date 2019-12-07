//
//  AboutViewController.swift
//  TJPhotoEditor
//
//  Created by Tom Shen on 02/08/2017.
//  Copyright © 2017 Tom and Jerry. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UIViewControllerTransitioningDelegate {
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let infoPlist = Bundle.main.infoDictionary!
        let version = infoPlist["CFBundleShortVersionString"]!
        let build = infoPlist["CFBundleVersion"]!
        
        versionLabel.text = NSLocalizedString("Version: ", comment: "Version Label Front") + "\(version) (\(build))"
        
        aboutLabel.text = NSLocalizedString("ABOUT_LABEL_TEXT", comment: "About Label Text")
        
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.layer.borderWidth = 5
        containerView.layer.cornerRadius = 13
        
        if #available(iOS 11, *) {
            containerView.accessibilityIgnoresInvertColors = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ExpandAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ShrinkDismissalAnimationController()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
