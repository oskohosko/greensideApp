# Greenside
A Golf Performance and Analysis Application.
Implemented for iOS using Swift, SwiftUI and UiKit, Greenside works in conjunction with a web application and companion watchOS application I am making.

It features a working, secure authentication system implemented in my Node.js and Express.js backend. It uses JWT/Bcrypt and saves tokens in cookies (for web) and Keychain (for iOS).

It uses GPS and Location data to fit holes within map regions, calculate distances and project club distance and dispersion onto the golf course.

The watchOS app saves shot data to the cloud which is fetched by both the iOS App and the Web App.

Data persistence methods I use include MongoDB (web), Firebase (web and mobile) and SwiftData (iOS).

## Screenshots
<p>
  <img src="/Screenshots/roundDetail.PNG" width=240 alt="Round detail view">
  <img src="/Screenshots/courseDetail.PNG" width=240 alt="Course detail view">
  <img src="/Screenshots/profile.PNG" width=240 alt="Profile view">
  <img src="/Screenshots/holeDetail.PNG" width=240 alt="Hole detail view">
  <img src="/Screenshots/rosebudAnnotations1.PNG" width=240 alt="Annotations">
  <img src="/Screenshots/rosebudAnnotations13.PNG" width=240 alt="Annotations">
  <img src="/Screenshots/projectClub.PNG" width=240 alt="Club projection sheet">
</p>

