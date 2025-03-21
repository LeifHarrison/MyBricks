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

protocol BarcodeScannerDelegate: AnyObject {
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
    @IBOutlet weak var instructionsContainerView: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var noCameraView: UIView!
    @IBOutlet weak var testBarcodesButton: UIView!
    @IBOutlet weak var scanAreaView: UIView!

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

    // -------------------------------------------------------------------------
    // MARK: - View Lifecycle
    // -------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.captureDevice != nil {
            setupCamera()
        }
        else {
            // Device doesn't support video capture. Display informational
            // overlay and, on the simulator, a "Test Barcodes" button
            noCameraView.isHidden = false
            
            if UIDevice.isSimulator {
                scanAreaView.layer.borderColor = UIColor.white.cgColor
                scanAreaView.layer.borderWidth = 2.0
                scanAreaView.layer.cornerRadius = 4.0
                
                testBarcodesButton.layer.cornerRadius = 5.0
                testBarcodesButton.isHidden = false
            }

            // Hide everything else
            instructionLabel.isHidden = true
            previewView.isHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.captureDevice != nil {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        ActivityOverlayView.hide()
        captureSession.stopRunning()
        super.viewWillDisappear(animated)
    }

    // -------------------------------------------------------------------------
    // MARK: - View Layout
    // -------------------------------------------------------------------------
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for output in captureSession.outputs {
            if let metadataOutput = output as? AVCaptureMetadataOutput {
                let regionOfInterest = previewView.regionOfInterest
                metadataOutput.rectOfInterest = previewView.videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: regionOfInterest)
            }
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    // -------------------------------------------------------------------------

    @IBAction func toggleTorch(_ sender: UIButton?) {
        if let selected = sender?.isSelected {
            toggleTorch(!selected)
            sender?.isSelected = !selected
        }
    }
    
    @IBAction func cancel(_ sender: UIButton?) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func showBarcodeTestMenu(_ sender: UIButton) {
        // swiftlint:disable comma
        let testItems = [
            [ "name" : "Invalid Code",      "code" : "3732300201",    "type" : "UPCA" ],
            [ "name" : "Not Found",         "code" : "010101010105",  "type" : "UPCA" ],
            [ "name" : "Adventure Camp Tree House",  "code" : "673419248259",  "type" : "org.gs1.UPC-A" ],
            [ "name" : "Stephanie's House", "code" : "673419265102",  "type" : "org.gs1.UPC-A" ],
            [ "name" : "Dragon Sanctuary",  "code" : "673419249393",  "type" : "org.gs1.UPC-A" ],
            [ "name" : "Battle on Scarif",  "code" : "673419265836",  "type" : "org.gs1.UPC-A" ]

        ]
        // swiftlint:enable comma

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for item in testItems {
            let action = UIAlertAction(title: item["name"], style: .default) { _ in
                self.delegate?.barcodeScanner(self, didCaptureCode: item["code"]!, type: item["type"]!)
            }
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Do nothing - alert will automatically dismiss
        }
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    // -------------------------------------------------------------------------
    // MARK: - Private
    // -------------------------------------------------------------------------

    private func setupCamera() {
        guard self.captureDevice != nil else {
            return
        }

        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authorizationStatus == .authorized {
            setupSession()
        }
        else if authorizationStatus == .notDetermined {
            let completion = { (granted: Bool) in
                DispatchQueue.main.async {
                    if granted {
                        self.setupSession()
                    }
                }
            }
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: completion)
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

    func toggleTorch(_ value: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = value ? .on : .off
                device.unlockForConfiguration()
            }
            catch {
                NSLog("Torch could not be used")
            }
        }
        else {
            NSLog("Torch is not available")
        }
    }
    
}

// =============================================================================
// MARK: - AVCaptureMetadataOutputObjectsDelegate
// =============================================================================

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
            ActivityOverlayView.show(overView: self.view)
        }

        delegate?.barcodeScanner(self, didCaptureCode: code, type: rawType)
    }
}
