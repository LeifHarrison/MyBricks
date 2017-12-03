//
//  BarcodeScannerViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/13/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - Delegates

protocol BarcodeScannerDelegate: class {
    func barcodeScanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String)
    func barcodeScanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error)
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerViewController)
}

extension AVMetadataObject.ObjectType {
    public static let upca: AVMetadataObject.ObjectType = AVMetadataObject.ObjectType(rawValue: "org.gs1.UPC-A")
}

class BarcodeScannerViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var instructionView: UIView!
    @IBOutlet weak var noCameraView: UIView!
    @IBOutlet weak var testBarcodesButton: UIView!

    weak var delegate: BarcodeScannerDelegate?

    let allowedMetadataObjectTypes = [
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.upce
    ]

    /// Video capture device.
    lazy var captureDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.video)
    /// Capture session.
    lazy var captureSession: AVCaptureSession = AVCaptureSession()
    /// Video preview layer.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    var isOneTimeSearch = true
    var locked = false

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        testBarcodesButton.layer.cornerRadius = 5.0

        if let _ = self.captureDevice {
            setupCamera()
        }
        else {
            // Device doesn't support video capture. Display informational
            // overlay and, on the simulator, a "Test Barcodes" button
            //noCameraView.isHidden = false
            if UIDevice.isSimulator {
                testBarcodesButton.isHidden = false
            }

            // Hide everything else
            //previewView.isHidden = true
            instructionView.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = self.captureDevice {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        activityIndicator?.stopAnimating()
        captureSession.stopRunning()
        super.viewWillDisappear(animated)
    }

    //--------------------------------------------------------------------------
    // MARK: - View Layout
    //--------------------------------------------------------------------------
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for output in captureSession.outputs {
            if let metadataOutput = output as? AVCaptureMetadataOutput {
                let regionOfInterest = previewView.regionOfInterest
                metadataOutput.rectOfInterest = previewView.videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: regionOfInterest)
            }
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func toggleTorch(_ sender: UIButton?) {
        if let selected = sender?.isSelected {
            toggleTorch(on: !selected)
            sender?.isSelected = !selected
        }
    }
    
    @IBAction func cancel(_ sender: UIButton?) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func showBarcodeTestMenu(_ sender: UIButton) {
        let testItems = [
            [ "name" : "Invalid Code",      "code" : "3732300201",    "type" : "UPCA" ],
            [ "name" : "Not Found",         "code" : "010101010105",  "type" : "UPCA" ],
            [ "name" : "Stephanie's House", "code" : "673419265102",  "type" : "org.gs1.UPC-A" ]
        ]
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for item in testItems {
            let action = UIAlertAction(title: item["name"], style: .default) { (action) in
                self.delegate?.barcodeScanner(self, didCaptureCode: item["code"]!, type: item["type"]!)
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

    private func setupCamera() {
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
    private func setupSession() {
        guard let device = self.captureDevice else {
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)
        }
        catch {
            delegate?.barcodeScanner(self, didReceiveError: error)
        }

        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = allowedMetadataObjectTypes
        previewView.videoPreviewLayer.session = captureSession
    }

    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = on ? .on : .off
                device.unlockForConfiguration()
            }
            catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    

}

//==============================================================================
// MARK: - AVCaptureMetadataOutputObjectsDelegate
//==============================================================================

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !locked else { return }
        guard !metadataObjects.isEmpty else { return }

        guard let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject, allowedMetadataObjectTypes.contains(metadataObject.type) else {
            return
        }

        guard var code = metadataObject.stringValue else {
            return
        }

        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        captureSession.stopRunning()

        var rawType = metadataObject.type.rawValue
        
        // UPC-A is an EAN-13 barcode with a zero prefix.
        // See: https://stackoverflow.com/questions/22767584/ios7-barcode-scanner-api-adds-a-zero-to-upca-barcode-format
        if metadataObject.type == AVMetadataObject.ObjectType.ean13 && code.hasPrefix("0") {
            code = String(code.dropFirst())
            rawType = AVMetadataObject.ObjectType.upca.rawValue
        }

        DispatchQueue.main.async {
            self.activityIndicator?.startAnimating()
        }

        delegate?.barcodeScanner(self, didCaptureCode: code, type: rawType)
    }
}
