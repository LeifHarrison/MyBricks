//
//  BarcodeScannerViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/13/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeScannerViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var focusView: UIView!
    @IBOutlet weak var instructionView: UIView!
    @IBOutlet weak var noCameraView: UIView!
    @IBOutlet weak var testBarcodesButton: UIView!

    let metadata = [
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.code39,
        AVMetadataObject.ObjectType.code39Mod43,
        AVMetadataObject.ObjectType.code93,
        AVMetadataObject.ObjectType.dataMatrix,
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.face,
        AVMetadataObject.ObjectType.interleaved2of5,
        AVMetadataObject.ObjectType.itf14,
        AVMetadataObject.ObjectType.pdf417,
        AVMetadataObject.ObjectType.qr,
        AVMetadataObject.ObjectType.upce,
    ]

    /// Video capture device.
    lazy var captureDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.video)
    /// Capture session.
    lazy var captureSession: AVCaptureSession = AVCaptureSession()
    /// Video preview layer.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        focusView.backgroundColor = UIColor.clear
        focusView.layer.borderColor = UIColor(white: 0.9, alpha: 0.9).cgColor
        focusView.layer.borderWidth = 3.0
        focusView.layer.cornerRadius = 4.0

        testBarcodesButton.layer.cornerRadius = 5.0

        // [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count]
        if let _ = self.captureDevice {
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            if let previewLayer = videoPreviewLayer {
                view.layer.insertSublayer(previewLayer, at: 0)
            }

            setupCamera()
        }
        else {
            // Device doesn't support video capture. Display informational
            // overlay and, on the simulator, a "Test Barcodes" button
            noCameraView.isHidden = false
            if UIDevice.isSimulator {
                testBarcodesButton.isHidden = false
            }

            // Hide everything else
            focusView.isHidden = true
            flashButton.isHidden = true
            instructionView.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLayout()
        if let _ = self.captureDevice {
            captureSession.startRunning()
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func cancel(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func showBarcodeTestMenu(_ sender: UIButton) {
        let testItems = [
            [ "name" : "Invalid Code",              "code" : "3732300201",    "type" : "UPCA" ],
            [ "name" : "Not Found",                 "code" : "010101010105",  "type" : "UPCA" ],
            [ "name" : "Test 1",            "code" : "673419292177",  "type" : "UPCA" ]
        ]
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for item in testItems {
            let action = UIAlertAction(title: item["name"], style: .default) { (action) in
                //self.processUPC(item["code"]!, withType: item["type"]!, isWatermark: false)
            }
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // Do nothing - alert will automatically dismiss
        }
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    func setupCamera() {
        guard let _ = self.captureDevice else {
            return
        }

        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authorizationStatus == .authorized {
            setupSession()
            //status = Status(state: .scanning)
        }
        else if authorizationStatus == .notDetermined {
            let completion = { (granted: Bool) -> Void in
                DispatchQueue.main.async {
                    if granted {
                        self.setupSession()
                    }

                    //self.status = granted ? Status(state: .scanning) : Status(state: .unauthorized)
                }
            }
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: completion)
        }
        else {
            //status = Status(state: .unauthorized)
        }
    }

    // Sets up capture input, output and session.
    func setupSession() {
        guard let device = self.captureDevice else {
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)
        } catch {
            //errorDelegate?.barcodeScanner(self, didReceiveError: error)
        }

        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = metadata
        videoPreviewLayer?.session = captureSession

        view.setNeedsLayout()
    }

    func updateLayout() {
        if let videoPreviewLayer = videoPreviewLayer {
            videoPreviewLayer.frame = view.layer.bounds
            if let connection = videoPreviewLayer.connection, connection.isVideoOrientationSupported {
                switch (UIApplication.shared.statusBarOrientation) {
                case .portrait: connection.videoOrientation = .portrait
                case .landscapeRight: connection.videoOrientation = .landscapeRight
                case .landscapeLeft: connection.videoOrientation = .landscapeLeft
                case .portraitUpsideDown: connection.videoOrientation = .portraitUpsideDown
                default: connection.videoOrientation = .portrait
                }
            }
        }
    }

}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //guard !locked else { return }
        guard !metadataObjects.isEmpty else { return }

        guard
            let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
            var code = metadataObj.stringValue,
            metadata.contains(metadataObj.type)
            else { return }

//        if isOneTimeSearch {
//            locked = true
//        }

//        var rawType = metadataObj.type.rawValue

        // UPC-A is an EAN-13 barcode with a zero prefix.
        // See: https://stackoverflow.com/questions/22767584/ios7-barcode-scanner-api-adds-a-zero-to-upca-barcode-format
        if metadataObj.type == AVMetadataObject.ObjectType.ean13 && code.hasPrefix("0") {
            code = String(code.dropFirst())
            //rawType = AVMetadataObject.ObjectType.upca.rawValue
        }

//        codeDelegate?.barcodeScanner(self, didCaptureCode: code, type: rawType)
//        animateFlash(whenProcessing: isOneTimeSearch)
    }
}
