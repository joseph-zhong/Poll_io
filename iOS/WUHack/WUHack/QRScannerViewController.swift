//
//  ViewController.swift
//  QRCodeTester
//
//  Created by Aneesh Sachdeva on 9/19/15.
//  Copyright (c) 2015 Applos. All rights reserved.
//

import UIKit
import AVFoundation
import Parse
import Bolts

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel! // this is just for debugging
    
    var foundQRCode : Bool = false
    var qrCodeMessage : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // TUTORIAL HERE --> http://www.appcoda.com/qr-code-reader-swift/ //
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        var error:NSError?
        let input: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        
        if (error != nil) {
            // If any error occurs, simply log the description of it and don't continue any more.
            println("\(error?.localizedDescription)")
            return
        }
        
        // Initialize the captureSession object.
        captureSession = AVCaptureSession()
        // Set the input device on the capture session.
        captureSession?.addInput(input as! AVCaptureInput)
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        // Start video capture.
        captureSession?.startRunning()
        
        // Move the labels to the top view
        view.bringSubviewToFront(titleLabel)
        //-view.bringSubviewToFront(messageLabel)
        
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
        
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                
                // Save message
                qrCodeMessage = metadataObj.stringValue
                //foundQRCode = true
                
                //captureSession?.stopRunning()
                
                // Join channel
                joinChannel(metadataObj.stringValue)
            }
        }
    }
    
    func joinChannel(channelID: String)
    {
        if !foundQRCode
        {
            foundQRCode = true
            
            var query = PFQuery(className: "UserChannels")
            query.whereKey("user", equalTo: PFUser.currentUser()!.objectId!)
            query.getFirstObjectInBackgroundWithBlock({
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil
                {
                    if object != nil
                    {
                        var userChannels : PFObject = object!
                        var channels = userChannels.objectForKey("Channels") as! [String]
                        
                        // Check to see if user has joined channel already
                        var userHasJoinedChannelBefore : Bool = false
                        for channel in channels
                        {
                            if channel == channelID
                            {
                                userHasJoinedChannelBefore = true
                            }
                        }
                        if !userHasJoinedChannelBefore
                        {
                            channels.append(channelID)
                            
                            userChannels.setObject(channels, forKey: "Channels")
                            userChannels.saveInBackgroundWithBlock({
                                (success, error) -> Void in
                                if error == nil
                                {
                                    if success == true
                                    {
                                        // User joined channel!
                                        var query = PFQuery(className: "Channel")
                                        query.getObjectInBackgroundWithId(channelID, block: {
                                            (channel, error) -> Void in
                                            self.showSuccess(channel!.objectForKey("name") as! String)
                                        })
                                        
                                    }
                                }
                            })

                        }
                        else // stop the process
                        {
                            println("We kinda gucci")
                            
                            var alert = UIAlertController(title: "Yo", message: "You've already joined this channel!", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
                                (UIAlertAction) -> Void in
                                
                                //self.foundQRCode = false // reset value
                            }
                            
                            alert.addAction(alertAction)
                            
                            self.presentViewController(alert, animated: true) { () -> Void in }
                        }
                    }
                }
            })
        }
    }
    
    func showSuccess(channelName: String)
    {
        println("We kinda gucci")
        
        var alert = UIAlertController(title: "You're in", message: "Successfully joined \(channelName)!", preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
            (UIAlertAction) -> Void in
            
            //self.foundQRCode = false // reset value
        }
        
        alert.addAction(alertAction)
        
        self.presentViewController(alert, animated: true) { () -> Void in }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createNonInterpolatedUIImageFromCIImage(image: CIImage, scale: CGFloat) -> UIImage
    {
        // Render the CIImage into a CGImage
        var cgImage = CIContext(options: nil).createCGImage(image, fromRect: image.extent())
        
        // Now we'll rescale using CoreGraphics
        UIGraphicsBeginImageContext(CGSizeMake(image.extent().size.width * scale, image.extent().size.width * scale))
        var context = UIGraphicsGetCurrentContext()
        
        // We don't want to interpolate (since we've got a pixel-correct image)
        CGContextSetInterpolationQuality(context, kCGInterpolationNone)
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage)
        
        // Get the image out
        var scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // Tidy up
        UIGraphicsEndImageContext()
        //CGImageRelease(cgImage); // deprecated, I believe
        
        return scaledImage
    }
}

