//
//  ViewController.swift
//  TJPhotoEditor
//
//  Created by Tom Shen on 01/08/2017.
//  Copyright © 2017 Tom and Jerry. All rights reserved.
//

import UIKit
import AssetsLibrary
import MobileCoreServices
import LinkPresentation

class ViewController: UIViewController {
    @IBOutlet weak var placeholderImageView: UIImageView!
    
    @IBOutlet weak var rightToolbarFSItem: UIBarButtonItem!
    @IBOutlet weak var leftToolbarFSItem: UIBarButtonItem!
    
    // These three buttons has to be strong otherwise they will
    // disappear after they were initially removed
    @IBOutlet var editorButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var newImageButton: UIBarButtonItem!
    
    var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    //@IBOutlet weak var imageView: UIImageView!
    
    var firstTime: Bool = true
    
    var newImage = false
    
    override var keyCommands: [UIKeyCommand]? {
        let takePhotoCommand = UIKeyCommand(input: "T", modifierFlags: .command, action: #selector(takePhoto))
        takePhotoCommand.discoverabilityTitle = "Take Photo"
        
        let chooseFromLibraryCommand = UIKeyCommand(input: "L", modifierFlags: .command, action: #selector(chooseFromLibrary))
        chooseFromLibraryCommand.discoverabilityTitle = "Choose from Library"
        
        if imageView?.image != nil {
            let backToEditorCommand = UIKeyCommand(input: "E", modifierFlags: .command, action: #selector(backToEditor(_:)))
            backToEditorCommand.discoverabilityTitle = "Back to Editor"
            
            let saveImageCommand = UIKeyCommand(input: "S", modifierFlags: .command, action: #selector(saveImage(_:)))
            saveImageCommand.discoverabilityTitle = "Save Image"
            
            let shareImageCommand = UIKeyCommand(input: "S", modifierFlags: [.command, .alternate], action: #selector(shareCommandAction))
            shareImageCommand.discoverabilityTitle = "Share Image"
            
            return [takePhotoCommand, chooseFromLibraryCommand, backToEditorCommand, saveImageCommand, shareImageCommand]
        }
        
        return [takePhotoCommand, chooseFromLibraryCommand]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Configure Toolbar for initial load
        self.toolbarItems = [leftToolbarFSItem, newImageButton, rightToolbarFSItem]
        
        firstTime = true
        
        scrollView.isHidden = true
        
        if #available(iOS 11, *) {
            placeholderImageView.accessibilityIgnoresInvertColors = true
            
            customEnableDropping(on: view, dropInteractionDelegate: self)
        }
        /*
        for (UIGestureRecognizer *gestureRecognizer in scrollView.gestureRecognizers) {
            if ([gestureRecognizer  isKindOfClass:[UIPanGestureRecognizer class]]) {
                UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *) gestureRecognizer;
                panGR.minimumNumberOfTouches = 2;
            }
        }
 */
        /*
         // Open this when drag and drop is supported and add a if for iPad
        for recognizer: UIGestureRecognizer in scrollView.gestureRecognizers! {
            if recognizer.isKind(of: UIPanGestureRecognizer.self) {
                let panRecognizer = recognizer as! UIPanGestureRecognizer
                panRecognizer.minimumNumberOfTouches = 2
            }
        }
 */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if firstTime == false {
            // Make sure the view is centered
            //self.imageScrollView.contentOffset.y += 64
            
            if newImage == true {
                if imageView != nil {
                    fixZoomScale(animated: true)
                }
                
                newImage = false
            }
        }
    }

    @IBAction func newImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let sheetTitle = NSLocalizedString("Select Photo Source", comment: "Action sheet title")
            let actionSheet = UIAlertController(title: sheetTitle, message: nil, preferredStyle: .actionSheet)
            
            let action1Title = NSLocalizedString("Choose from Photo Library", comment: "Choose from Photo Library action")
            let choosePhotoAction = UIAlertAction(title: action1Title, style: .default, handler: { action in
                self.chooseFromLibrary()
            })
            
            let action2Title = NSLocalizedString("Take Photo", comment: "Take Photo action")
            let cameraAction = UIAlertAction(title: action2Title, style: .default, handler: { action in
                self.takePhoto()
            })
            
            let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel action title")
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
            
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(choosePhotoAction)
            actionSheet.addAction(cancelAction)
            
            actionSheet.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
            
            present(actionSheet, animated: true, completion: nil)
        } else {
            chooseFromLibrary()
        }
    }

    @objc func chooseFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func takePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imageFinishedEditing(_ image: UIImage) {
        if firstTime == true {
            // Update View
            self.toolbarItems = [saveButton, shareButton, editorButton, leftToolbarFSItem, newImageButton]
            
            // Add a blur andn make the background half transparentt
            placeholderImageView.alpha = 0.4
            
            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            visualEffectView.frame = placeholderImageView.bounds
            visualEffectView.tag = 1000
            placeholderImageView.addSubview(visualEffectView)
            
            placeholderImageView.contentMode = .scaleAspectFill
            
            firstTime = false
        }
        
        // PLaceholder image view is now a blurred version
        placeholderImageView.image = image
        
        if imageView == nil {
            scrollView.isHidden = false
            
            imageView = UIImageView()
            
            imageView.contentMode = .scaleToFill
            
            scrollView.addSubview(imageView)
            
            scrollView.delegate = self
        }
        
        imageView.image = image
        imageView.sizeToFit()
        scrollView.contentSize = image.size
        
        let centerPoint = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
        view(imageView, setCenter: centerPoint)
        
        if #available(iOS 11, *) {
            imageView.accessibilityIgnoresInvertColors = true
            
            customEnableDragging(on: imageView, dragInteractionDelegate: self)
        }
    }
    
    @IBAction func saveImage(_ sender: Any) {
        let image = imageView.image!
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWith:contextInfo:)), nil)
    }
    
    @IBAction func shareImage(_ sender: Any) {
        let image = imageView.image!
        let shareSheet = UIActivityViewController(activityItems: [image, self], applicationActivities: nil)
        shareSheet.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        present(shareSheet, animated: true, completion: nil)
    }
    
    @IBAction func backToEditor(_ sender: Any) {
        let editor = CLImageEditor(image: imageView.image)!
        editor.modalPresentationStyle = .fullScreen
        editor.delegate = self
        present(editor, animated: true, completion: nil)
    }
    
    @objc func shareCommandAction() {
        shareImage(shareButton as Any)
    }
    
    @objc func image(_ image: UIImage?, didFinishSavingWith error: NSError?, contextInfo: UnsafeRawPointer) {
        let title: String
        let message: String
        if error == nil {
            //title = "Success"
            title = NSLocalizedString("Success", comment: "Save alert success title")
            //message = "Successfully saved image to library."
            message = NSLocalizedString("Successfully saved image to library.", comment: "Save alert success message")
        } else {
            //title = "Failure"
            title = NSLocalizedString("Failure", comment: "Save alert fail title")
            //message = "Error saving message: \(error!.localizedDescription)"
            message = NSLocalizedString("Error saving message: ", comment: "Save alert fail message") + (error!.localizedDescription)
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func fixZoomScale(animated: Bool) {
        let widthRatio = scrollView.frame.width / imageView.image!.size.width
        let heightRatio = scrollView.frame.height / imageView.image!.size.height
        
        scrollView.contentSize = imageView.frame.size
        scrollView.maximumZoomScale = 1
        
        let minZoom = min(min(widthRatio, heightRatio), 1)
        
        scrollView.minimumZoomScale = minZoom
        
        if minZoom == 1 {
            // If minZoom is 1 (for whatever reason I am not going to investigate),
            // just hack it by making maxZoom bigger.
            scrollView.maximumZoomScale = 5
        }
        
        scrollView.setZoomScale(minZoom, animated: animated)
    }
}

// MARK: - Rotation
extension ViewController {
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if imageView != nil {
            // Just enlarge the blur view before rotation
            let backgroundVEView = placeholderImageView.viewWithTag(1000)!
            backgroundVEView.frame.size = CGSize(width: backgroundVEView.frame.size.width * 2, height: backgroundVEView.frame.size.height * 2)
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if imageView != nil {
            let backgroundVEView = placeholderImageView.viewWithTag(1000)!
            backgroundVEView.frame = placeholderImageView.bounds
            
            UIView.animate(withDuration: 0.1, animations: {
                let centerPoint = CGPoint(x: self.scrollView.bounds.midX, y: self.scrollView.bounds.midY)
                self.view(self.imageView, setCenter: centerPoint)
            })
            
            fixZoomScale(animated: true)
        }
    }
}

// MARK: - Image Picker Delegate
extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        
        picker.dismiss(animated: true, completion: nil)
        let imageEditor = CLImageEditor(image: image)!
        imageEditor.delegate = self
        imageEditor.modalPresentationStyle = .fullScreen
        present(imageEditor, animated: true, completion: nil)
    }
}

// MARK: - Image Editor Delegate

extension ViewController: CLImageEditorDelegate {
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        editor.dismiss(animated: true, completion: nil)
        
        // Fix zoom scale on iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Hack in a delay so that it will actually do it.
            let time = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                if self.imageView != nil {
                    let backgroundVEView = self.placeholderImageView.viewWithTag(1000)!
                    backgroundVEView.frame = self.placeholderImageView.bounds
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        let centerPoint = CGPoint(x: self.scrollView.bounds.midX, y: self.scrollView.bounds.midY)
                        self.view(self.imageView, setCenter: centerPoint)
                    })
                    
                    self.fixZoomScale(animated: true)
                }
            })
        }
    }
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        // Remove previous image if exists
        if imageView != nil {
            imageView.removeFromSuperview()
            imageView = nil
        }

        // Process image
        self.imageFinishedEditing(image)
        
        self.newImage = true
        
        editor.dismiss(animated: true, completion: nil)
        
        // Fix zoom scale on iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Hack in a delay so that it will actually do it.
            let time = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                if self.imageView != nil {
                    let backgroundVEView = self.placeholderImageView.viewWithTag(1000)!
                    backgroundVEView.frame = self.placeholderImageView.bounds
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        let centerPoint = CGPoint(x: self.scrollView.bounds.midX, y: self.scrollView.bounds.midY)
                        self.view(self.imageView, setCenter: centerPoint)
                    })
                    
                    self.fixZoomScale(animated: true)
                }
            })
        }
    }
}

// MARK: - Scroll View Delegate

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let zoomView = scrollView.delegate!.viewForZooming!(in: scrollView)!
        var zoomViewFrame = zoomView.frame
        if zoomViewFrame.size.width < scrollView.bounds.size.width {
            zoomViewFrame.origin.x = (scrollView.bounds.size.width - zoomViewFrame.size.width) / 2
        } else {
            zoomViewFrame.origin.x = 0
        }
        
        if zoomViewFrame.size.height < scrollView.bounds.size.height {
            zoomViewFrame.origin.y = (scrollView.bounds.size.height - zoomViewFrame.size.height) / 2
        } else {
            zoomViewFrame.origin.y = 0
        }
        zoomView.frame = zoomViewFrame
    }
    
    func view(_ view: UIView, setCenter centerPoint: CGPoint) {
        var viewFrame = view.frame
        var contentOffset = scrollView.contentOffset
        
        let x = centerPoint.x - viewFrame.size.width / 2
        let y = centerPoint.y - viewFrame.size.height / 2
        
        if x < 0 {
            contentOffset.x = -x
            viewFrame.origin.x = 0
        } else {
            viewFrame.origin.x = x
        }
        
        if y < 0 {
            contentOffset.y = -y
            viewFrame.origin.y = 0.0
        } else {
            viewFrame.origin.y = y
        }
        
        view.frame = viewFrame
        scrollView.contentOffset = contentOffset
    }
}

// MARK: - Drag and Drop
extension ViewController: UIDragInteractionDelegate, UIDropInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let itemProvider = NSItemProvider(item: imageView.image!, typeIdentifier: kUTTypeImage as String)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.items.count == 1 && session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String])
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        let itemProvider = session.items[0].itemProvider
        itemProvider.loadObject(ofClass: UIImage.self) { (item, error) in
            if let image = item as? UIImage {
                DispatchQueue.main.async {
                    self.imageFinishedEditing(image)
                    self.backToEditor(self)
                }
            }
        }
    }
    
    func customEnableDragging(on view: UIView, dragInteractionDelegate: UIDragInteractionDelegate) {
        let dragInteraction = UIDragInteraction(delegate: dragInteractionDelegate)
        view.addInteraction(dragInteraction)
    }
    
    func customEnableDropping(on view: UIView, dropInteractionDelegate: UIDropInteractionDelegate) {
        let dropInteraction = UIDropInteraction(delegate: dropInteractionDelegate)
        view.addInteraction(dropInteraction)
    }
}

// MARK: - Activity Helper
extension ViewController: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        guard let image = imageView.image else { return nil }
        let imageProvider = NSItemProvider(object: image)
        let metadata = LPLinkMetadata()
        metadata.imageProvider = imageProvider
        metadata.title = "Share image"
        return metadata
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
