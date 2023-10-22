//
//  ContentView.swift
//  ImageClassificationSwiftUI
//
//  Created by Mohammad Azam on 2/3/20.
//  Copyright © 2020 Mohammad Azam. All rights reserved.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    let photos = (1...8).map { "\($0)" }.shuffled()
    @State private var currentIndex: Int = 0
    @State private var classificationLabel: String = ""
    
    var body: some View {
        VStack {
            Image(photos[currentIndex])
            .resizable()
                .frame(width: 200, height: 200)
            HStack {
                Button("Previous") {
                    
                    if self.currentIndex >= self.photos.count {
                        self.currentIndex = self.currentIndex - 1
                    } else {
                        self.currentIndex = 0
                    }
                    
                    }.padding()
                    .foregroundColor(Color.white)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .frame(width: 100)
                
                Button("Next") {
                    if self.currentIndex < self.photos.count - 1 {
                        self.currentIndex = self.currentIndex + 1
                    } else {
                        self.currentIndex = 0
                    }
                }
                .padding()
                .foregroundColor(Color.white)
                .frame(width: 100)
                .background(Color.gray)
                .cornerRadius(10)
            
                
                
            }.padding()
            
            Button("Classify") {
              
                
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
        
                
            }.padding()
            .foregroundColor(Color.white)
            .background(Color.green)
            .cornerRadius(8)
            
            Text(classificationLabel)
                .font(.largeTitle)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
