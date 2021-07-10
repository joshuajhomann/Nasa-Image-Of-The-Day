# Sample projects for Flock of Swifts meetup on 10-July-2021

Code along project designed to show how to use async / await with SwiftUI in iOS 15 beta.

We dicussed:
  * The Nasa  Astronomy Picture of the Day API: https://api.nasa.gov
  * decoding the response with Quicktype: https://quicktype.io
  * cleaning up the type to remove optional elements, use strong typing for `URL`, and make the resulting struct `Identifiable` so it works in a `SwiftUI.List`
  * build a `URL` with `URLComponents`
  * making an async initializer for `Result`
  * making an async network request and decoding the response
  * switching over the images enum to handle loading, error and loaded states
  * Using the new `AsyncImage` API
  * Using the new `.task` modifier to start an async task that is automatically scoped to the lifetime of the view
  * using the new `.refreshable` modifier to implement pull to refresh  
  
![image](./preview.gif "Preview")
