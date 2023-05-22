//
//  ViewController.swift
//  cameraCapture
//
//  Created by abdullah's Ventura on 22.05.2023.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    var chosenImage = CIImage()
    
    @IBOutlet weak var resultLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func buton(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Which source you want to use to select photo?", preferredStyle: .actionSheet)
           
           let selectPhoto = UIAlertAction(title: "Select Photo from Library", style: .default) { _ in
               self.preparePickerController(picker2: .photoLibrary)
           }
           
           let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { _ in
               self.preparePickerController(picker2: .camera)
           }
           
           alert.addAction(selectPhoto)
           alert.addAction(takePhoto)
           
           // Modally bir UIAlertController'ı göstermek yerine, mevcut ViewController üzerinde bir popover olarak gösterin.
           alert.popoverPresentationController?.sourceView = self.view
           alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
           alert.popoverPresentationController?.permittedArrowDirections = []
           
           present(alert, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.dismiss(animated: true, completion: nil)
                if let ciImage = CIImage(image: image) {
                    chosenImage = ciImage
                    recognizeImage(image: chosenImage)
                }
            }
    }
    
    func preparePickerController(picker2: UIImagePickerController.SourceType){
       let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = picker2
        present(picker, animated: true)
    }
    func recognizeImage(image: CIImage) {
        
        // 1) Request
        // 2) Handler
        
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            //
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            
                            let rounded = Int (confidenceLevel * 100) / 100
                            
                            //
                            let alert = UIAlertController(title:"Enchantment Accuracy:\(rounded)", message: "This is a \(topResult!.identifier) ", preferredStyle: .actionSheet)
                            let okBtn = UIAlertAction(title: "wingardium leviosa", style: .cancel) { alert in
                                self.imageView.image = UIImage(named: "")
                            }
                            alert.popoverPresentationController?.sourceView = self.view
                            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                            alert.popoverPresentationController?.permittedArrowDirections = []
                            alert.addAction(okBtn)
                            self.present(alert, animated: true)
                            
                        }
                        
                    }
                    
                }
                
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
                  DispatchQueue.global(qos: .userInteractive).async {
                    do {
                    try handler.perform([request])
                    } catch {
                        print("error")
                    }
            }
            
            
        }
        
      
        
    }
}

