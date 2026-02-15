//
//  CameraView.swift
//  camera-mobile-app-1
//
//  Created by Julio Guzman on 2/10/26.
//

import SwiftUI
import AVFoundation

// Wrapper to make UIImage Identifiable for sheet(item:)
struct ImageWrapper: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct CameraView: View {
    @EnvironmentObject var nutritionViewModel: NutritionViewModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var cameraManager = CameraManager()
    @State private var capturedImage: UIImage?
    @State private var pendingImage: ImageWrapper?
    
    // Meal form fields
    @State private var mealName = ""
    @State private var calories: Double = 0
    @State private var protein: Double = 0
    @State private var carbs: Double = 0
    @State private var fats: Double = 0
    @State private var healthyFats: Double = 0
    @State private var saturatedFats: Double = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let image = capturedImage {
                    // Show captured image with form
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                            .padding()
                        
                        mealFormView
                    }
                } else {
                    // Camera preview
                    CameraPreviewView(cameraManager: cameraManager)
                        .ignoresSafeArea()
                    
                    // Dark overlay with clear center third horizontally (horizontal strip - full width, center third of height)
                    GeometryReader { geometry in
                        let screenWidth = geometry.size.width
                        let screenHeight = geometry.size.height
                        
                        // Center third horizontally = horizontal strip (full width, center third of height)
                        let clearAreaHeight = screenHeight / 3
                        let clearAreaTop = screenHeight / 3
                        let clearAreaBottom = clearAreaTop + clearAreaHeight
                        let clearAreaCenterY = screenHeight / 2
                        
                        ZStack {
                            // Top third - dimmed
                            Rectangle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: screenWidth, height: clearAreaTop)
                                .position(x: screenWidth / 2, y: clearAreaTop / 2)
                            
                            // Bottom third - dimmed
                            Rectangle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: screenWidth, height: screenHeight - clearAreaBottom)
                                .position(x: screenWidth / 2, y: clearAreaBottom + (screenHeight - clearAreaBottom) / 2)
                            
                            // Very subtle border for the clear area (horizontal strip)
                            Rectangle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                .frame(width: screenWidth, height: clearAreaHeight)
                                .position(x: screenWidth / 2, y: clearAreaCenterY)
                        }
                    }
                    .ignoresSafeArea()
                    
                    VStack {
                        // "Add Meal" title above the square
                        VStack {
                            Text("Add Meal")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.top, 60)
                            Spacer()
                        }
                        
                        VStack {
                            Spacer()
                            
                            // Capture button
                            Button(action: {
                                print("🟡 CameraView: Capture button tapped")
                                // Capture full photo - we'll crop when displaying/saving
                                cameraManager.capturePhoto(cropToSquare: false) { image in
                                    DispatchQueue.main.async {
                                        if let image = image {
                                            self.pendingImage = ImageWrapper(image: image)
                                        }
                                    }
                                }
                            }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray, lineWidth: 3)
                                            .frame(width: 60, height: 60)
                                    )
                            }
                            .padding(.bottom, 50)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .sheet(item: $pendingImage) { wrapper in
                PhotoApprovalView(
                    image: wrapper.image,
                    onApprove: {
                        // Crop to center third before saving
                        capturedImage = CameraView.cropToCenterThird(wrapper.image)
                        pendingImage = nil
                    },
                    onRetake: {
                        pendingImage = nil
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                cameraManager.checkPermission()
            }
            .onDisappear {
                cameraManager.stopSession()
            }
        }
    }
    
    private var mealFormView: some View {
        Form {
            Section(header: Text("Meal Information")) {
                TextField("Meal Name", text: $mealName)
                    .textInputAutocapitalization(.words)
            }
            
            Section(header: Text("Nutritional Information")) {
                HStack {
                    Text("Calories")
                    Spacer()
                    TextField("0", value: $calories, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Protein (g)")
                    Spacer()
                    TextField("0", value: $protein, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Carbs (g)")
                    Spacer()
                    TextField("0", value: $carbs, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Total Fats (g)")
                    Spacer()
                    TextField("0", value: $fats, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Healthy Fats (g)")
                    Spacer()
                    TextField("0", value: $healthyFats, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Saturated Fats (g)")
                    Spacer()
                    TextField("0", value: $saturatedFats, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
            }
            
            Section {
                Button(action: saveMeal) {
                    Text("Save Meal")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(
                    LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .disabled(mealName.isEmpty)
            }
        }
    }
    
    private func saveMeal() {
        // Crop to center third before saving
        let croppedImage = capturedImage != nil ? CameraView.cropToCenterThird(capturedImage!) : nil
        let imageData = croppedImage?.jpegData(compressionQuality: 0.8)
        
        let meal = Meal(
            name: mealName.isEmpty ? "Meal" : mealName,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fats: fats,
            healthyFats: healthyFats,
            saturatedFats: saturatedFats,
            imageData: imageData
        )
        
        nutritionViewModel.addMeal(meal)
        resetForm()
        dismiss()
    }
    
    // Helper function to crop image to center third horizontally (vertical strip - full height, center third of width)
    static func cropToCenterThird(_ image: UIImage) -> UIImage {
        // Get the actual CGImage size (this is the true pixel dimensions, not affected by orientation)
        guard let cgImage = image.cgImage else {
            return image
        }
        
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        // Calculate center third horizontally (33.33% of width)
        let centerThirdWidth = imageWidth / 3.0
        let centerThirdLeft = imageWidth / 3.0
        
        print("🟢 CropToCenterThird:")
        print("   CGImage size: \(imageWidth) x \(imageHeight)")
        print("   Center third width: \(centerThirdWidth) (33.33% of \(imageWidth))")
        print("   Center third left: \(centerThirdLeft)")
        print("   Crop area: from \(centerThirdLeft) to \(centerThirdLeft + centerThirdWidth)")
        
        let cropRect = CGRect(
            x: centerThirdLeft,
            y: 0,
            width: centerThirdWidth,
            height: imageHeight
        )
        
        print("   Crop rect: \(cropRect)")
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            print("🔴 Failed to crop, returning original")
            return image
        }
        
        let croppedImage = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
        print("🟢 Cropped image size: \(croppedImage.size)")
        print("   Actual percentage: \((croppedCGImage.width / cgImage.width) * 100)%")
        return croppedImage
    }
    
    private func resetForm() {
        mealName = ""
        calories = 0
        protein = 0
        carbs = 0
        fats = 0
        healthyFats = 0
        saturatedFats = 0
        capturedImage = nil
    }
}

// Camera Preview View
struct CameraPreviewView: UIViewRepresentable {
    let cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        cameraManager.setupPreview(in: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update if needed
    }
}

// Image Picker for selecting from photo library
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// Photo Approval Modal
struct PhotoApprovalView: View {
    let image: UIImage
    let onApprove: () -> Void
    let onRetake: () -> Void
    
    // Helper function to crop image to center third horizontally (full height, center third of width)
    private func cropToCenterThird(_ image: UIImage) -> UIImage {
        return CameraView.cropToCenterThird(image)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Text("Review Photo")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Show only center third of the image
                Image(uiImage: cropToCenterThird(image))
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    // Retake button
                    Button(action: onRetake) {
                        Text("Retake")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(12)
                    }
                    
                    // Approve button
                    Button(action: onApprove) {
                        Text("Use Photo")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CameraView()
        .environmentObject(NutritionViewModel())
}
