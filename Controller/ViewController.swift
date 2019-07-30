//
//  ViewController.swift
//  imageRec
//
//  Created by Duale on 7/29/19.
//  Copyright © 2019 Duale. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Social

class ViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    var str : String = "Most Likely 1: ", str2  = "Most Likely 2: "
    let imgpicker = UIImagePickerController()
//     var secondRes : VNClassificationObservation
    override func viewDidLoad() {
        super.viewDidLoad()
        imgpicker.delegate = self
        labelFirst.text = str
        labelSec.text = str2
        fitIntoLabel()
        Coloring()
    }


    @IBOutlet weak var labelFirst: UILabel!
    @IBOutlet weak var labelSec: UILabel!
    @IBOutlet weak var imageViewCaptured: UIImageView!
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imgpicker.sourceType = .camera
        imgpicker.allowsEditing = true
        present(imgpicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            imageViewCaptured.image = image

            imgpicker.dismiss(animated: true, completion: nil)


            guard let ciImage = CIImage(image: image) else {
                fatalError("couldn't convert uiimage to CIImage")
            }

            detectImage(image: ciImage)

        }
       
        
         imgpicker.dismiss(animated: true, completion: nil)
    }
    
    func detectImage (image : CIImage)  {
      
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("No image ")
        }
    
        let request = VNCoreMLRequest(model: model) { request, error in
            
           
            guard let results = request.results as? [VNClassificationObservation],
                let firstIndexRes = results.first
                else {
                    fatalError("error from VNCoreMLRequest")
            }
            print(results)
              print("====")
            print(Int(results.first?.confidence ?? 0))
              print("====")


            
            self.labelFirst.text =  self.getFirstIdentifier(str: firstIndexRes.identifier) + ",   Confidence %: " +
                String(firstIndexRes.confidence)
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                    self.navigationController?.navigationBar.isTranslucent = false

            
            if let res = request.results as! [VNClassificationObservation]? {
                 let secondRes =  res[1]
                self.labelSec.text =  self.getFirstIdentifier(str: secondRes.identifier) + ",   Confidence %: " +
                    String(secondRes.confidence)
            }
        }
        
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do { try handler.perform([request]) }
        catch { print(error) }
        
    }
    
    func fitIntoLabel () {
      labelFirst.adjustsFontSizeToFitWidth = true
      labelFirst.textAlignment = NSTextAlignment.center
        labelSec.adjustsFontSizeToFitWidth = true
        labelSec.textAlignment = NSTextAlignment.center
    }
    
    func getFirstIdentifier (str : String) -> String {
        let strword = str.components(separatedBy: ",")
        return strword[0]
    }
    
    func Coloring () {
        navigationController?.navigationBar.barTintColor = .black
        labelFirst.textColor = .white
        labelSec.textColor = .white
        labelSec.backgroundColor = .blue
        labelFirst.backgroundColor = .blue
    }
    
   
}

