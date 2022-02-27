//
//  MakeIconSet.swift
//  IconsetCreator
//
//  Created by Mark Erbaugh on 11/3/21.
//

import Foundation
import AppKit
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let appiconset = UTType(exportedAs: "com.microenh.appiconset")
}

struct IconSet {
    let useMac: Bool
    let useiPad: Bool
    let useiPhone: Bool
    let image: NSImage
    let destination: URL
    
    
    private static let mac = [
        [CGFloat(16), CGFloat(1)],
        [16, 2],
        [32, 1],
        [32, 2],
        [128, 1],
        [128, 2],
        [256, 1],
        [256, 2],
        [512, 1],
        [512, 2]
    ]
    
    private static let iPad = [
        [CGFloat(20), CGFloat(1)],
        [20, 2],
        [29, 1],
        [29, 2],
        [40, 1],
        [40, 2],
        [76, 1],
        [76, 2],
        [83.5, 2],
    ]
    
    private static let iPhone = [
        [CGFloat(20), CGFloat(2)],
        [20, 3],
        [29, 1],
        [29, 2],
        [29, 3],
        [40, 2],
        [40, 3],
        [60, 2],
        [60, 3],
    ]
    
    private static let ios = [
        [CGFloat(1024), CGFloat(1)]
    ]
    
    private var sizes: [CGFloat] {
        var result = Set<CGFloat>()
        if useMac {
            for size in IconSet.mac {
                result.insert(size[0] * size[1])
            }
        }
        if useiPad {
            for size in IconSet.iPad {
                result.insert(size[0] * size[1])
            }
        }
        if useiPhone {
            for size in IconSet.iPhone {
                result.insert(size[0] * size[1])
            }
        }
        if useiPad || useiPhone {
            for size in IconSet.ios {
                result.insert(size[0] * size[1])
            }
        }
        return Array(result).sorted()
    }
    
    private func filename(size: CGFloat, scale: CGFloat = 1) -> String {
        "\(Int(size * scale)).png"
    }
    
    private func contentDictionary(for idiom: String, size: CGFloat, scale: CGFloat) -> String {
        // let sizeString = CGFloat(Int(size)) == size ? "\(Int(size))x\(Int(size))" : "\(size)x\(size)"
        let s = String(format: modf(size).1 > 0 ? "%.1f" : "%.0f", size)
        let sizeString = "\(s)x\(s)"
        return """
            {
              "filename": "\(filename(size: size, scale: scale))",
              "idiom": "\(idiom)",
              "scale": "\(Int(scale))x",
              "size": "\(sizeString)"
            },
        
        """
    }
    
    private var contents: String {
        var result = """
        {
          "images": [
        
        """
        if useMac {
            for sizes in IconSet.mac {
                result.append(contentDictionary(for: "mac", size: sizes[0], scale: sizes[1]))
            }
        }
        if useiPad {
            for sizes in IconSet.iPad {
                result.append(contentDictionary(for: "ipad", size: sizes[0], scale: sizes[1]))
            }
        }
        if useiPhone {
            for sizes in IconSet.iPhone {
                result.append(contentDictionary(for: "iphone", size: sizes[0], scale: sizes[1]))
            }
        }
        if useiPad || useiPhone {
            for sizes in IconSet.ios {
                result.append(contentDictionary(for: "ios-marketing", size: sizes[0], scale: sizes[1]))
            }
        }
        result.append("""
          ],
          "info": {
            "author": "com.microenh.appiconset",
            "version": 1
          }
        }
        
        """)
        return result
    }
    
    func make() throws {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: destination)
        } catch {
        }
        try fileManager.createDirectory(atPath: destination.path, withIntermediateDirectories: false)
        for i in sizes {
            let new_pic = ResizeImage(image: image, targetSize: CGSize(width: i/2, height: i/2))
            
            let fileURL = destination.appendingPathComponent("\(Int(i)).png")
        
            if let imagedata = new_pic.tiffRepresentation {
                try NSBitmapImageRep(data: imagedata)?
                    .representation(using: .png, properties: [:])!
                    .write(to: fileURL)
            }
        }
        try contents.write(to: destination.appendingPathComponent("Contents.json"), atomically: true, encoding: String.Encoding.utf8)
    }
    
    func ResizeImage(image: NSImage, targetSize: CGSize) -> NSImage {
        let screenScale = NSScreen.main!.backingScaleFactor
        let scaleFactor = max(image.size.width / targetSize.width,
                              image.size.height / targetSize.height)
        
        let newSource = CGSize(width: targetSize.width * scaleFactor, height: targetSize.height * scaleFactor)
        let center = CGPoint(x: image.size.width / screenScale, y: image.size.height / screenScale)
        
        let newImage = NSImage(size: targetSize)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, targetSize.width, targetSize.height),
                   from: NSMakeRect(center.x - newSource.width / 2,
                                    center.y - newSource.height / 2,
                                    newSource.width, newSource.height),
                   operation: NSCompositingOperation.copy, fraction: CGFloat(1))
        newImage.unlockFocus()
        return newImage
    }

    // doesn't work if aspect ratios of source and target are different
    func OldResizeImage(image: NSImage, targetSize: CGSize) -> NSImage {
        let size = image.size

        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        // let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        // NSGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        
        
        var square = newSize
        
        square.height = square.width
        
        let newImage = NSImage(size: square)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, (square.height - newSize.height) / 2, newSize.width, newSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: NSCompositingOperation.copy, fraction: CGFloat(1))
        // newImage.size = newSize
        newImage.unlockFocus()
        // let newImage1 = newImage.roundCorners(withRadius: 10)

        return newImage
    }

    
}
