import UIKit
import Photos

func sectionTitleFor(index: Int) -> String {
     return "Section \(index)"
}

struct Photo {
    enum Size {
        case Small, Large
    }

    var remoteID: String
    var placeholder = UIImage(named: "clear.png")!
    var url: String?
    var local: Bool = false
    static let NumberOfSections = 20

    init(remoteID: String) {
        self.remoteID = remoteID
    }

    func media(completion: (image: UIImage?, error: NSError?) -> ()) {
        if self.local {
            if let asset = PHAsset.fetchAssetsWithLocalIdentifiers([self.remoteID], options: nil).firstObject {
                Photo.resolveAsset(asset as! PHAsset, size: .Large, completion: { image in
                    completion(image: image, error: nil)
                })
            }
        } else {
            completion(image: self.placeholder, error: nil)
        }
    }

    static func constructRemoteElements() -> [String : [Photo]] {
        var sections = [String : [Photo]]()

        for section in 0..<Photo.NumberOfSections {
            var elements = [Photo]()
            for row in 0..<10 {
                var photo = Photo(remoteID: "\(section)-\(row)")

                let index = Int(arc4random_uniform(6))
                switch index {
                case 0:
                    photo.placeholder = UIImage(named: "0.jpg")!
                    break
                case 1:
                    photo.placeholder = UIImage(named: "1.jpg")!
                    break
                case 2:
                    photo.placeholder = UIImage(named: "2.jpg")!
                    break
                case 3:
                    photo.placeholder = UIImage(named: "3.jpg")!
                    break
                case 4:
                    photo.placeholder = UIImage(named: "4.jpg")!
                    break
                case 5:
                    photo.placeholder = UIImage(named: "5.png")!
                    photo.url = "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_20mb.mp4"
                default: break
                }
                elements.append(photo)
            }
            sections[sectionTitleFor(section)] = elements
        }

        return sections
    }

    static func resolveAsset(asset: PHAsset, size: Photo.Size, completion: (image: UIImage?) -> Void) {
        let imageManager = PHImageManager.defaultManager()
        let requestOptions = PHImageRequestOptions()
        requestOptions.networkAccessAllowed = true
        if size == .Small {
            let targetSize = CGSize(width: 300, height: 300)
            imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: requestOptions) { image, info in
                if let info = info where info["PHImageFileUTIKey"] == nil {
                    completion(image: image)
                }
            }
        } else {
            requestOptions.version = .Original
            imageManager.requestImageDataForAsset(asset, options: requestOptions) { data, _, _, _ in
                if let data = data, image = UIImage(data: data) {
                    completion(image: image)
                } else {
                    fatalError("Couldn't get photo")
                }
            }
        }
    }

    static func checkAuthorizationStatus(completion: (success: Bool) -> Void) {
        let currentStatus = PHPhotoLibrary.authorizationStatus()

        guard currentStatus != .Authorized else {
            completion(success: true)
            return
        }

        PHPhotoLibrary.requestAuthorization { authorizationStatus in
            dispatch_async(dispatch_get_main_queue(), {
                if authorizationStatus == .Denied {
                    completion(success: false)
                } else if authorizationStatus == .Authorized {
                    completion(success: true)
                }
            })
        }
    }
}
