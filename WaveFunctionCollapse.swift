import Foundation
import AppKit

/*
 Wave Function Collapse C Implementation: Swift Bridge Interface
    Source: https://github.com/krychu/wfc
 */

struct WaveFuncCollapse {
    
    static func run(imageNamed name: String, n: Int32, width: Int32, height: Int32) -> Array2d<rgb>? {
        guard let image = NSImage(named: name) else { print("Could not find NSImage named '\(name)'") ; return nil }
        
        // Get pixel data from image via CGContext
        let size = image.size
        let dataSize = size.width * size.height * 4
        
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        
        let context = CGContext(
            data: &pixelData,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 4 * Int(size.width),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        )
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Could not get cgImage from NSImage") ; return nil
        }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Create new pixel array and only add RGB components, no Alpha channel
        var compressedPixelData = [UInt8]()
        for i in 0..<Int(size.width * size.height) {
            let r = pixelData[i*4]
            let g = pixelData[i*4 + 1]
            let b = pixelData[i*4 + 2]
            compressedPixelData.append(r)
            compressedPixelData.append(g)
            compressedPixelData.append(b)
        }
        
        // Create pointer to compressedPixelData (cannot directly use UnsafeMutablePointer<UInt8> because of dangling pointer)
        let imageDataPtr = compressedPixelData.withUnsafeMutableBytes {
            (ptr: UnsafeMutableRawBufferPointer) -> UnsafeMutablePointer<UInt8> in
            let imageDataPtr = ptr.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return imageDataPtr
        }
        
        // Create image with data and size
        var WFCImage = wfc_image(
            data: imageDataPtr,
            component_cnt: 3,
            width: Int32(size.width), height: Int32(size.height)
        )
        
        // Create the Wave Function Collapse model
        var newWFC = wfc_overlapping(
            width, height,      // Width and height of image
            &WFCImage,          // wfc_image object
            n, n,               // Size of patterns
            1, 1, 1, 1          // Flags
        )
        
        // Run the model with n iterations
        wfc_run(newWFC, 10000)
        
        // Returns a pointer to a wfc_image object, destroy model when done
        let outputImg = wfc_output_image(newWFC)
        wfc_destroy(newWFC)
        
        // Resolve the pointer and optional
        if let imageData = outputImg?.pointee as? wfc_image {
            // wfc_image.data is a pointer to an array of char values (0-255) to represent color components
            // Need to retrieve it as a buffer from memory like so
            let arraySize = imageData.width * imageData.height * imageData.component_cnt
            let bufferPointer = UnsafeBufferPointer(start: imageData.data, count: Int(arraySize))

            // Convert the buffer to an array of UInt8 values (0-255)
            let dataArray = Array(bufferPointer)
            
            // Draw pixels to a 2d Array object and return
            var outputArray = Array2d<rgb>(width: Int(width), height: Int(height))
            for i in 0..<Int(width * height) {
                let r = dataArray[i*3   ]
                let g = dataArray[i*3 + 1]
                let b = dataArray[i*3 + 2]
                
                let x = i % Int(height)
                let y = i / Int(width)
                
                outputArray[x,y] = [Int(r),Int(g),Int(b)]
            }
            
            return outputArray
        } else {
            print("Could not resolve wfc_image pointer")
        }
        return nil
    }
    struct Array2d<T> {
        let width, height: Int
        var array: [[T?]]
        init(width: Int, height: Int) {
            self.width = width ; self.height = height
            self.array = [[T?]](repeating: [T?](repeating: nil, count: height), count: width)
        }
        func inRange(_ x: Int, _ y: Int) -> Bool { x >= 0 && x < width && y >= 0 && y < height }
        subscript(x: Int, y: Int) -> T? {
            get { guard inRange(x, y) else { return nil } ; return array[x][y] }
            set { guard inRange(x, y) else { return } ; array[x][y] = newValue }
        }
    }
    struct rgb: ExpressibleByArrayLiteral {
        let r, g, b: Int
        init(arrayLiteral values: Int...) {
            guard values.count >= 3 else { r = 0 ; g = 0 ; b = 0 ; return }
            r = values[0] ; g = values[1] ; b = values[2]
        }
    }
}
