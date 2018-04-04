# hawk-eye-sim

Small toy app using Matlab to test some image processing operations simulating a Tennis Hawk Eye.
The scripts received as input a simplified image of a tennis court, a tennis ball over the court (or None) and some additional data (like the tpe of game Single or Doubles). Using different image operations and techniques the script return as output if the ball is IN or OUT the valid area of the tennis court.

## Screenshots

<img src="imgs_doc/tennis_court_shot_002_tif_DOUBLES_LEFT_SERVICE_LEFT_IN.png" width="250">
<img src="imgs_doc/tennis_court_shot_003_tif_DOUBLES_LEFT_SERVICE_LEFT_OUT.png" width="250">

## Requirements

To run this application a version of [Matlab](https://la.mathworks.com/products/matlab.html) is needed.

## Run the examples

* [imhawkeye.m](imhawkeye.m): implements the algorithm
* [imhawkeye_test.m](imhawkeye_test.m): run a buch of test using different input images
