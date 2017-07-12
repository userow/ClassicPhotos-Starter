//
//  PhotoOperations.swift
//  ClassicPhotos
//
//  Created by Pavel Wasilenko on 11.07.17.
//  Copyright © 2017 raywenderlich. All rights reserved.
//

import Foundation
import UIKit

enum PhotoRecordState {
    case New, Downloaded, Filtered, Failed
}

class PhotoRecord {
    let name:String
    let url:URL
    var state = PhotoRecordState.New
    var image = UIImage(named: "Placeholder")
    
    init(name:String, url:URL) {
        self.name = name
        self.url = url
    }
    
}

class PendingOperations {
    lazy var downloadsInProgress = [NSIndexPath:Operation]()
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = QualityOfService.userInitiated
        return queue
    }()
    
    lazy var filtrationsInProgress = [NSIndexPath:Operation]()
    lazy var filtrationQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = QualityOfService.utility
        return queue
    }()
}


class ImageDownloader: Operation {
    //1
    let photoRecord: PhotoRecord
    
    //2
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    //3
    override func main() {
        //4
        if self.isCancelled {
            return
        }
        //5
        let imageData = try? Data(contentsOf:self.photoRecord.url)
        
        //6
        if self.isCancelled {
            return
        }
        
        //7
        if imageData!.count > 0 {
            self.photoRecord.image = UIImage(data:imageData!)
            self.photoRecord.state = PhotoRecordState.Downloaded
        }
        else
        {
            self.photoRecord.state = PhotoRecordState.Failed
            self.photoRecord.image = UIImage(named: "Failed")
        }
    }

    func applySepiaFilter(image:UIImage) -> UIImage? {
        let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
        
        if self.isCancelled {
            return nil
        }
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        filter!.setValue(0.8, forKey: "inputIntensity")
        let outputImage = filter!.outputImage
        
        if self.isCancelled {
            return nil
        }
        
        let outImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let returnImage = UIImage(cgImage: outImage!)
        return returnImage
    }
}
