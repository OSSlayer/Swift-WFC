# Swift Wave Function Collapse Interface
A Wave Function Collapse interface in Swift using krychu's C implementation (Link: https://github.com/krychu/wfc)

  NOTE: I did not write the actual wave function collapse algorithm. krychu wrote it and please refer to the linked repository for that.
  
This is an interface to easily use the WFC algorithm in Swift. 
Add the files to your project and put the path to the bridger file in the project files (guide below)

# Usage

```
let outputimage = WaveFuncCollapse.run(
  imageNamed: "",     // Name of image to load (ex. image name in .xcassets folder)
  n: 3,               // Size of patterns to get from input image
  width: 20,          // Width of output image
  height: 20          // Height of output image
}
```

# Built In Classes

There are two classes in the WaveFuncCollapse Struct: `rgb` and `Array2d`

The `rgb` class is a simple struct holding `r`, `g`, and `b` values and can be expressed by a `[r,g,b]` array
The `Array2d` class is a 2d array implementation. It contains a 2d array of optional values for any specified type. 
  To read values from the array simply do:
  ```
    let value = array[x,y]  // Read
    array[x,y] = newValue   // Write
  ```
  
  The `Array2d` class has built in checks for whether or not the x and y are in bounds of the `width` and `height` properties of the array.
  
  To loop through every value:
  ```
    for x in 0..<array.width {
      for y in 0..<array.height {
        // do something with x and y
      }
    }
  ```
  
# Adding the Bridging Header to your Project
To add the Bridging Header under your Build go to Project -> Targets -> Build Settings and search "bridging header". 
  The result should come up under 'Swift Compiler - General' under 'Objective-C Bridging Header'
  Put the path to the bridging header here
