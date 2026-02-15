//
//  CameraManager.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import AVFoundation
import UIKit

class CameraManager: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let photoOutput = AVCapturePhotoOutput()
    
    @Published var permissionGranted = false
    
    override init() {
        super.init()
        setupSession()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        self?.startSession()
                    }
                }
            }
        default:
            permissionGranted = false
        }
    }
    
    private func setupSession() {
        captureSession.sessionPreset = .photo
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput),
              captureSession.canAddOutput(photoOutput) else {
            return
        }
        
        captureSession.addInput(videoInput)
        captureSession.addOutput(photoOutput)
    }
    
    func setupPreview(in view: UIView) {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.bounds
        
        if let previewLayer = videoPreviewLayer {
            view.layer.addSublayer(previewLayer)
            // Update frame when view bounds change
            DispatchQueue.main.async {
                previewLayer.frame = view.bounds
            }
        }
    }
    
    func startSession() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    private var currentPhotoDelegate: PhotoCaptureDelegate?
    
    func capturePhoto(cropToSquare: Bool = false, completion: @escaping (UIImage?) -> Void) {
        guard captureSession.isRunning else {
            print("🔴 CameraManager: Capture session is not running")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        print("🟢 CameraManager: Starting photo capture...")
        let settings = AVCapturePhotoSettings()
        
        // Retain the delegate to prevent deallocation
        let delegate = PhotoCaptureDelegate(cropToSquare: cropToSquare, previewLayer: videoPreviewLayer) { [weak self] image in
            self?.currentPhotoDelegate = nil
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        currentPhotoDelegate = delegate
        photoOutput.capturePhoto(with: settings, delegate: delegate)
        print("🟢 CameraManager: Photo capture request sent")
    }
}

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    private let cropToSquare: Bool
    private weak var previewLayer: AVCaptureVideoPreviewLayer?
    
    init(cropToSquare: Bool = false, previewLayer: AVCaptureVideoPreviewLayer?, completion: @escaping (UIImage?) -> Void) {
        self.cropToSquare = cropToSquare
        self.previewLayer = previewLayer
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("🔴 PhotoCaptureDelegate: Error capturing photo - \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.completion(nil)
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("🔴 PhotoCaptureDelegate: Failed to get image data")
            DispatchQueue.main.async {
                self.completion(nil)
            }
            return
        }
        
        guard let image = UIImage(data: imageData) else {
            print("🔴 PhotoCaptureDelegate: Failed to create UIImage from data")
            DispatchQueue.main.async {
                self.completion(nil)
            }
            return
        }
        
        print("🟢 PhotoCaptureDelegate: Photo captured successfully, size: \(image.size)")
        
        if cropToSquare, let previewLayer = previewLayer {
            print("🟢 PhotoCaptureDelegate: Cropping image to center third...")
            // Crop to the center third area
            if let croppedImage = cropImageToSquare(image, previewLayer: previewLayer) {
                print("🟢 PhotoCaptureDelegate: Crop successful, size: \(croppedImage.size)")
                DispatchQueue.main.async {
                    self.completion(croppedImage)
                }
            } else {
                print("🔴 PhotoCaptureDelegate: Crop failed, returning original")
                DispatchQueue.main.async {
                    self.completion(image)
                }
            }
        } else {
            print("🟢 PhotoCaptureDelegate: No crop requested, returning original")
            DispatchQueue.main.async {
                self.completion(image)
            }
        }
    }
    
    private func cropImageToSquare(_ image: UIImage, previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
        // Get the screen dimensions
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // The clear area is the center third: full width, 1/3 height
        let clearAreaTop = screenHeight / 3
        let clearAreaHeight = screenHeight / 3
        
        // Get image size
        let imageSize = image.size
        let previewFrame = previewLayer.frame
        let previewBounds = previewLayer.bounds
        
        print("🟢 Crop calculation:")
        print("   Screen: \(screenWidth) x \(screenHeight)")
        print("   Clear area: top=\(clearAreaTop), height=\(clearAreaHeight)")
        print("   Image: \(imageSize)")
        print("   Preview frame: \(previewFrame)")
        print("   Preview bounds: \(previewBounds)")
        
        // Use frame if bounds are zero (happens sometimes)
        // Also check the actual layer's presentation frame
        let layerFrame = previewLayer.frame
        let effectivePreviewWidth = previewBounds.width > 0 ? previewBounds.width : (previewFrame.width > 0 ? previewFrame.width : layerFrame.width)
        let effectivePreviewHeight = previewBounds.height > 0 ? previewBounds.height : (previewFrame.height > 0 ? previewFrame.height : layerFrame.height)
        
        print("   Layer frame: \(layerFrame)")
        print("   Effective preview: \(effectivePreviewWidth) x \(effectivePreviewHeight)")
        
        guard effectivePreviewWidth > 0 && effectivePreviewHeight > 0 else {
            print("🔴 Invalid preview dimensions (all zero), returning original")
            print("   This means the preview layer isn't properly set up yet")
            return image
        }
        
        // Convert screen coordinates to normalized preview coordinates (0.0 to 1.0)
        // The clear area in normalized coordinates
        let normalizedTop = clearAreaTop / screenHeight
        let normalizedHeight = clearAreaHeight / screenHeight
        
        print("   Normalized: top=\(normalizedTop), height=\(normalizedHeight)")
        
        // Account for aspect fill - the preview might show more/less of the image
        let previewAspect = effectivePreviewWidth / effectivePreviewHeight
        let imageAspect = imageSize.width / imageSize.height
        
        var cropRect: CGRect
        
        if previewAspect > imageAspect {
            // Preview is wider - image fills height, cropped on sides
            let scale = imageSize.height / effectivePreviewHeight
            let visibleWidth = effectivePreviewWidth * scale
            let offsetX = (imageSize.width - visibleWidth) / 2
            
            cropRect = CGRect(
                x: offsetX,
                y: normalizedTop * imageSize.height,
                width: visibleWidth,
                height: normalizedHeight * imageSize.height
            )
            print("   Preview wider: scale=\(scale), offsetX=\(offsetX)")
        } else {
            // Preview is taller - image fills width, cropped on top/bottom
            let scale = imageSize.width / effectivePreviewWidth
            let visibleHeight = effectivePreviewHeight * scale
            let offsetY = (imageSize.height - visibleHeight) / 2
            
            cropRect = CGRect(
                x: 0,
                y: offsetY + (normalizedTop * visibleHeight),
                width: imageSize.width,
                height: normalizedHeight * visibleHeight
            )
            print("   Preview taller: scale=\(scale), offsetY=\(offsetY)")
        }
        
        print("   Crop rect: \(cropRect)")
        print("   Expected ratio: \(cropRect.width / cropRect.height) (should be ~3:1)")
        
        // Ensure crop rect is within image bounds
        let clampedRect = cropRect.intersection(CGRect(origin: .zero, size: imageSize))
        
        print("   Final clamped rect: \(clampedRect)")
        print("   Clamped ratio: \(clampedRect.width / clampedRect.height)")
        
        guard clampedRect.width > 0 && clampedRect.height > 0,
              clampedRect.width <= imageSize.width && clampedRect.height <= imageSize.height,
              let cgImage = image.cgImage?.cropping(to: clampedRect) else {
            print("🔴 Failed to crop image (invalid rect or cgImage), returning original")
            print("   Original image size: \(imageSize)")
            return image
        }
        
        let croppedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        print("🟢 Cropped successfully: \(croppedImage.size), ratio: \(croppedImage.size.width / croppedImage.size.height)")
        return croppedImage
    }
}
