//
//  ViewController.swift
//  AlbumApp
//
//  Created by REO HARADA on 2019/02/02.
//  Copyright © 2019年 reo harada. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    var images: [NCMBFile] = []
    var cache: [String:Data] = [String:Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let xib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        self.albumCollectionView.register(xib, forCellWithReuseIdentifier: "imgCell")
        
        NCMB.setApplicationKey("fb2e810af40e559d06478eea30924a2523293dd4a42bc61c70fad96e1b14e118", clientKey: "105886742ada1f577b54f5f25ca7664569b8f348bac6cfded691842072eacfed")
        let data = try! NCMBFile.query()?.findObjects() as! [NCMBFile]
        self.images = data
        albumCollectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.albumCollectionView.dequeueReusableCell(withReuseIdentifier: "imgCell", for: indexPath) as! ImageCollectionViewCell
        cell.imgView.image = nil
        if self.cache[self.images[indexPath.row].name] != nil {
            cell.imgView.image = UIImage(data: self.cache[self.images[indexPath.row].name]!)
        }
        else {
            self.images[indexPath.row].getDataInBackground({ (data, error) in
                self.cache[self.images[indexPath.row].name] = data!
                cell.imgView.image = UIImage(data: data!)
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.size.width / 2 - 5
        return CGSize(width: size, height: size)
    }

    @IBAction func tapCameraButton(_ sender: Any) {
        let imgPicker = UIImagePickerController()
        imgPicker.sourceType = .camera
        imgPicker.delegate = self
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func tapPhotoLibrary(_ sender: Any) {
        let imgPicker = UIImagePickerController()
        imgPicker.sourceType = .photoLibrary
        imgPicker.delegate = self
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        NCMB.setApplicationKey("fb2e810af40e559d06478eea30924a2523293dd4a42bc61c70fad96e1b14e118", clientKey: "105886742ada1f577b54f5f25ca7664569b8f348bac6cfded691842072eacfed")
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = formatter.string(from: now)
        let data = img.jpegData(compressionQuality: 0.5)
        let file = NCMBFile.file(withName: fileName+".jpg", data: data) as! NCMBFile
        file.save(nil)
        self.images.append(file)
        self.albumCollectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
}

