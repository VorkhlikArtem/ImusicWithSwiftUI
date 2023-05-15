# Imusic
The application is similar to Apple Music. It consists of functionality for working with music files, finding and playing tracks from the iTunes API, saving your favorite tracks to the device's memory using UserDefaults, and much more. Great attention was paid to working with animations, a custom animated transition to the track playback screen was implemented, just like in a real Apple Music app.   

## Technology Stack 
* UIKit + SwiftUI architecture
* iTunes API as a backend server
* Alamofire library to request data from the network
* SDWebImage(UIKit) and URLImage(SwiftUI) libraries for loading images
* AVKit Audio Player to play music files
* CocoaPods and SPM 

## Additional capabilities 
* Creating animated transitions with Auto Layout   
* UIPanGestureRecognizer(UIKit), LongPressGesture(SwiftUI) 
* Saving favorite tracks to the device memory with UserDefaults  
* Programmatically designed UI with NSLayoutConstraints + XIB
* A draggable Track Detail Player is available between all application screens  

## Requirements
- IPhone 11+
- iOS 13.0+
