//
//  ViewController.swift
//  Week3FIlterApp
//
//  Created by Bradley Johnson on 8/4/14.
//  Copyright (c) 2014 learnswift. All rights reserved.
//

import UIKit
import Photos


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate,PhotoSelectedDelegate {
    
    @IBOutlet weak var photoButton: UIButton!
    
    let photoPicker = UIImagePickerController()
    let cameraPicker = UIImagePickerController()
    var imageViewSize : CGSize!
    let alertView = UIAlertController(title: "Alert!", message: "stop", preferredStyle: UIAlertControllerStyle.Alert)
       var actionController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
    var adjustmentFormatterIdentifier = "com.example.filterapp.cf"
    var asset : PHAsset?
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupActionController()
        
        self.photoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.photoPicker.allowsEditing = true
        self.photoPicker.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.imageViewSize = self.imageView.frame.size
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "ShowGrid" {
            
            let gridVC = segue.destinationViewController as GridViewController
            //fetching all assets without any options - gives us all the users photos
            gridVC.assetsFetchResult = PHAsset.fetchAssetsWithOptions(nil)
            gridVC.delegate = self
        }
    }
    
    func setupActionController() {
        
        self.actionController = UIAlertController(title: "Title", message: "message", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if self.actionController.popoverPresentationController {
            //self.actionController.modalPresentationStyle = UIModalPresentationStyle.Popover
            self.actionController.popoverPresentationController.sourceView = self.photoButton
        }
        self.actionController.modalPresentationStyle = UIModalPresentationStyle.PageSheet
        let cameraAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {( action: UIAlertAction!) -> Void in
            //present the camera picker
            //self.presentViewController(self.actionController, animated: true, completion: nil)
            
            })
        let photoAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {(action : UIAlertAction!) -> Void in
            //present the photo library
            self.performSegueWithIdentifier("ShowGrid", sender: self)
                      })
        self.actionController.addAction(cameraAction)
        self.actionController.addAction(photoAction)

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func applySepiaFilter(sender: AnyObject) {
        
        var options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(data : PHAdjustmentData!) -> Bool in
        
        return data.formatIdentifier == self.adjustmentFormatterIdentifier && data.formatVersion == "1.0"
        }
        
        self.asset!.requestContentEditingInputWithOptions(options, completionHandler: { (contentEditingInput : PHContentEditingInput!, info : [NSObject : AnyObject]!) -> Void in
        // get location of the photo
            var url = contentEditingInput.fullSizeImageURL
            var orientation = contentEditingInput.fullSizeImageOrientation
            var inputImage = CIImage(contentsOfURL: url)
            inputImage = inputImage.imageByApplyingOrientation(orientation)
            
            var filterName = "CISepiaTone"
            //add filter to the photo
            var filter = CIFilter(name: "CISepiaTone")
            filter.setDefaults()
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            var outputImage = filter.outputImage as CIImage
            
            //get the jpeg data
            var context = CIContext(options: nil)
            var cgimg = context.createCGImage(outputImage, fromRect: outputImage.extent())
            
            var finalImage = UIImage(CGImage: cgimg)
        self.imageView.image = finalImage
            
            var jpegData = UIImageJPEGRepresentation(finalImage, 0.8)
            
           
            //create the editing output
            var adjustmentData = PHAdjustmentData(formatIdentifier:self.adjustmentFormatterIdentifier, formatVersion: "1.0", data: filterName.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true))
//
           var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
//            
            jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
            contentEditingOutput.adjustmentData = adjustmentData
          
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                
                var request = PHAssetChangeRequest(forAsset: self.asset)
                request.contentEditingOutput = contentEditingOutput
                
                }, completionHandler: { (success : Bool, error: NSError!) -> Void in
                
                    if !success {
                        println(error.localizedDescription)
                    }
            })
            
            
            
        })
        
        
        
    }
    @IBAction func handlePhotoButtonPressed(sender: AnyObject) {
        
        if self.actionController.popoverPresentationController {
            self.actionController.popoverPresentationController.sourceView = self.photoButton
        }
        
        self.presentViewController(self.actionController, animated: true, completion: nil)
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        
        var editedImage = info[UIImagePickerControllerEditedImage] as UIImage
        
//        //creating graphics context
//         UIGraphicsBeginImageContextWithOptions(self.imageViewSize, true, UIScreen.mainScreen().scale)
//        let context = UIGraphicsGetCurrentContext()
//        CGContextTranslateCTM(context, 0.0, self.imageViewSize.height)
//        CGContextScaleCTM(context, 1.0, -1.0)
//        //drawing image in context
//        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: self.imageViewSize.width, height: self.imageViewSize.height), editedImage.CGImage)
//        //getting output image from context
//        var outputImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        println("Edited Image Size: \(editedImage.size)")
//        
//        var outputImage = UIImage(CGImage: editedImage.CGImage, scale: 0.5, orientation: editedImage.imageOrientation)
//        
//        println("Output Image Size: \(outputImage.size)")

        self.imageView.image = editedImage
        self.dismissViewControllerAnimated(true, completion: nil)
        editedImage.CIImage
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        println("user canceled")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: PhotoSelectedDelegate
    func photoSelected(asset : PHAsset) -> Void {
        println("final step")
        
        var targetSize = CGSize(width: CGRectGetWidth(self.imageView.frame), height: CGRectGetHeight(self.imageView.frame))
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            
            self.imageView.image = image
            
            self.asset = asset
        }
    }

}

