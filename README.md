### Steps to be taken, using `Turi Create`

1. Install Python Using Anaconda
2. Downloading Images from Dataset
3. Training Model Using `Turi Create`
4. Integrating Model with iOS App

### Objective

- You can create `.mlmodel` files with python

### Install Anaconda

- https://www.anaconda.com/
- Python 3.6.10 Version

### Anaconda Commands

```shell

# Check Environment
conda info --envs

# Check Python Version
python --version

# Create Environment
conda create -n "DevEnv36" python=3.6

```

### Dataset

https://image-net.org/

### Install Dependency for Python

```python
pip install requests
pip install turicreate
```

### Python Code to download images

```python

import os
import requests

def make_directories(directory_name):
    if not os.path.exists(directory_name):
        os.makedirs(directory_name)
        print('Directory has been created!')
    else:
        print('Directory already exists!')

def download_and_save_images(url, directory_name):
    list = requests.get(url).text.split('\r\n')[:50]

    for url in list:
        filename = os.path.basename(url)
        print(filename)
        try:
            with open(f"{directory_name}/{filename}","wb") as file_object:
                file_object.write(requests.get(url, timeout=1).content)
        except:
            print(f"Error downloading {filename}")
            continue

cat_url = "http://image-net.org/api/text/imagenet.synset.geturls?wnid=n02123045"
dog_url = "http://image-net.org/api/text/imagenet.synset.geturls?wnid=n02111277"

current_directory = os.getcwd()
cats_directory = current_directory + "/train/cats"
dogs_directory = current_directory + "/train/dogs"

make_directories(cats_directory)
make_directories(dogs_directory)

download_and_save_images(cat_url,cats_directory)
download_and_save_images(dog_url, dogs_directory)

```

### Python Code to train using `turicreate`

```python
import turicreate as tc

data = tc.image_analysis.load_images("train",with_path=True)

data['label'] = data['path'].apply(lambda path: 'dog' if '/dogs' in path else 'cat')

(train_data, test_data) = data.random_split(0.8)

model = tc.image_classifier.create(data, target='label')

predictions = model.predict(data)

model.export_coreml('CatDogClassifier.mlmodel')
```

### Swift

```swift
DispatchQueue.global().async {
            guard
                let model = try? CatDogClassifier(configuration: MLModelConfiguration()),
                let img = UIImage(named: self.photos[self.currentIndex])
            else { return }
            let resizedImage = img.resizeTo(size: CGSize(width: 224, height: 224))
            guard
                let buffer = resizedImage.toBuffer(),
                let output = try? model.prediction(image: buffer)
            else { return }
            DispatchQueue.main.async {
                self.classificationLabel = output.label
            }

        }

```

```swift

import Foundation
import UIKit

extension UIImage {

    func resizeTo(size :CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }

    func toBuffer() -> CVPixelBuffer? {

        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }

}


```
