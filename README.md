# MetalImageFramework
A framework that allows you to apply Metal filters to your images
## Installation
### SPM
Click on `Add Package Dependencies...` in Xcode, and paste the link to this repo (`https://github.com/greedy-dev/MetalImageFramework.git`), <br />
**or** <br />
add the following to your `Package.swift`
```swift
dependencies: [
    .package(url: "https://github.com/greedy-dev/MetalImageFramework.git", from: "0.0.2")
]
```
### CocoaPods
Add the following line to your `Podfile`
```
pod 'MetalImageFramework', '0.0.2'
```

## Usage
### Creating a view and adding image
Use `MetalImageView` to display the images, `ImageInput` for image to process, and `BasicShaderOperation` for some image filter
#### Sample code
```swift
let image = UIImage(named: "test_image")!
input = ImageInput(image: image)
                
input => imageView
input.processImage()
```

### Applying filters
Use `input => filter => imageView`, and then `input.processImage()` to display the image with the filter applied. To clear the filter, use `imageView.sources.removeAtIndex(0)`
#### Sample code
```swift
func applyFilter(_ filter: BasicShaderOperation) {
    imageView.sources.removeAtIndex(0)                
    input => filter => imageView
    self.input.processImage()
}
```

### Chaining multiple filters
You can use `OperationGroup` to chain filters
### Sample code
```swift
let luminance = LuminanceAdjustment()
let contrast = ContrastAdjustment()
contrast.contrast = 2.0

let group = OperationGroup()

group.configureGroup{ input, output in
    input => self.boxBlur => self.contrast => output
}
```


### Writing custom filters
To write a custom filter, you can subclass `BasicShaderOperation` (or directly instantiate it).
You need to supply a fragment shader and number of inputs to it.
The code for simple one-input filter will look something like that:
```swift
let customFilter = BasicOperation(fragmentFunctionName: "customFragmentShader", numberOfInputs: 1)
```

