# Stories App – Instagram-like Stories Feature

A SwiftUI implementation of an Instagram-like Stories feature for iOS.

## Features

### Implemented Features
- **Story List Screen** with infinite pagination  
- **Seen/Unseen Indicators** using gradient rings  
- **Story Detail View** with full-screen experience  
- **Like/Unlike Functionality** with animations  
- **Persistent State** across app sessions  
- **Smooth Animations and Transitions**

### Upcoming Features (TODO)
- **Pull-to-Refresh** on the story list  
- **Instagram-like Gestures** (double-tap to like, swipe down to dismiss)

## Architecture

- **Programming Language**: Swift 6, with full concurrency checks  
- **Architecture**: MVVM with clear separation of concerns and modularization  
- **Reactive Programming**: Uses the `Observation` framework  
- **Performance Optimizations**: `LazyVStack`, media caching with preloading/clear, pagination  
- **Instagram-Inspired UX**: Gestures, animations, and visual design  
- **Dependencies**: [`swift-dependencies`](https://github.com/pointfreeco/swift-dependencies), [`Kingfisher`](https://github.com/onevcat/Kingfisher), [`Alamofire`](https://github.com/Alamofire/Alamofire)

## Demo

![Stories Demo](demo/stories-demo.gif)
