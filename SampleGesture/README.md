# Sample app for UI Gesture Recognizer

### Overview
- `Pan Gesture` are allowed only if `Pinch Gesture` have already been applied to the image
- Only one Gesture a per time
- `Pinch Gesture` zoom start from image center
- `Double Tap Gesture` restore the image 
- Single `Tap Gesture` is not implemented


### About Gesture and Transformation
- from apple's documentation about `transform` :
    When the value of this property is anything other than the identity transform, the value in the frame property is undefined and should be ignored.
- from apple's documentation about `frame center`
  The center point is specified in points in the coordinate system of its superview. Setting this property updates the origin of the rectangle in the frame property appropriately.
  Use this property, instead of the frame property, when you want to change the position of a view. The center point is always valid, even when scaling or rotation factors are applied to the view's transform. Changes to this property can be animated.

```
for that reason every reposition of the image after transform need to be calculate from image center
```
