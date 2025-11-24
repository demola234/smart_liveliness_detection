# Changelog 
## Version 0.2.0 - November 24, 2025
* Bug fixing, improvements and new features:

- This version has several improvements in anti-spoofing techniques:

- Anti-Spoofing Result Map
- Screen Glare Detection
- Motion Correlation Check
- Face Contour Analysis (Mask Detection)
- Details:
- Bug fixing: Ignoring wrong error message (errorProcessing) after session.isComplete. 
- Bug fixing: Fixing glare detection method and adding option to enable/disable it. 
- Improving verifyMotionCorrelation method. Now checking both X and Y axes. 
- Adding params to enable/disable motion correlation detection. 
- Adding mask detection feature by detection face contours (The user can choose to enable/disable this feature, as well as the number of contours detected. The user can also choose which types of challenges will be checked). 
- Anti-spoofing settings: Screen reflection detection and missing facial contour detection no longer block liveness detection. 
- Anti-spoofing detection is configured in the metadata under antiSpoofingDetection flags (Anti-Spoofing Result Map), without preventing successful results.

## Version 0.2.0 - October 25, 2025
* Added support for new liveness challenges: "Raise Eyebrows" and "Open Mouth"
* Improved face detection accuracy with updated ML models
* Enhanced UI customization options for better theming
* Fixed minor bugs and improved overall performance

## 0.1.3 - April 25, 2025
* Google ML Kit upgraded to version 0.11.0
* Bug fixes and improvements

## 0.1.1 - April 24, 2025
* Bug fixes and improvements

## 0.1.0 - April 24, 2025
* Bug fixes and improvements
* Android fix initialization fix


## 0.0.1-beta.5 - April 23, 2025
* Bug fixes and improvements
* Android fix initialization fix


## 0.0.1 - Initial Release (April 15, 2025)

* Initial release of the Face Liveness Detection package
* Features included:
  * Multiple liveness challenge types (blinking, smiling, head turns, nodding)
  * Random challenge sequence generation
  * Face centering guidance with visual feedback
  * Anti-spoofing measures
  * Customizable UI with theming support
  * Animated progress indicators and overlays
  * Optional image capture capability

  