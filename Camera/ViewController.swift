//
//  ViewController.swift
//  Camera
//
//  Created by Eduardo Vital Alencar Cunha on 29/05/17.
//  Copyright © 2017 Vital. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var CIFilterNames = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"
    ]

    @IBOutlet weak var filtersScrollView: UIScrollView!
    @IBOutlet weak var selectedCamera: UISegmentedControl!

    @IBOutlet weak var pictureImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    func createFilters() {
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 5
        let buttonWidth:CGFloat = 55
        let buttonHeight: CGFloat = 70
        let gapBetweenButtons: CGFloat = 5

        var itemCount = 0
        filtersScrollView.subviews.map { $0.removeFromSuperview() }

        for i in 0..<CIFilterNames.count {
            itemCount = i

            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
            filterButton.tag = itemCount
            filterButton.addTarget(self, action: #selector(self.filterButtonTapped) , for: .touchUpInside)
            filterButton.layer.cornerRadius = 6
            filterButton.clipsToBounds = true

            // Create filters for each button
            let ciContext = CIContext(options: nil)
            let coreImage = CIImage(image: pictureImageView.image!)
            let filter = CIFilter(name: "\(CIFilterNames[i])" )
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)

            let imageForButton = UIImage(cgImage: filteredImageRef!, scale: 1, orientation: .right)

            // Assign filtered image to the button
            filterButton.setBackgroundImage(imageForButton, for: .normal)

            // Add Buttons in the Scroll View
            xCoord +=  buttonWidth + gapBetweenButtons

            filtersScrollView.addSubview(filterButton)
        }

        filtersScrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount + 2), height: yCoord)
    }

    func filterButtonTapped(sender: UIButton) {
        let button = sender as UIButton

        pictureImageView.image = button.backgroundImage(for: UIControlState.normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePicture(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()

            imagePicker.delegate = self
            imagePicker.sourceType = .camera

            if self.selectedCamera.selectedSegmentIndex == 0 { // 1 is for rear, 0 to front
                imagePicker.cameraDevice = .front
            }

            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    @IBAction func savePicture(_ sender: UIButton) {
        let imgData = UIImagePNGRepresentation(pictureImageView.image!)

        let image = UIImage(data: imgData!)

        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)

        let alert = UIAlertController(title: "Imagem Salva", message: "Sua imagem foi salva com sucesso na sua galeria de imagens", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func searchPicture(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true

            self.present(imagePicker, animated: true, completion: nil)
        }
    }


}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let infoImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pictureImageView.contentMode = .scaleAspectFit
            pictureImageView.image = infoImage
        }

        picker.dismiss(animated: true, completion: self.createFilters)
    }
}
