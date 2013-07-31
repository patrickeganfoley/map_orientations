#include <iostream>
#include <math.h>
#include <complex>
using namespace std;

//  This file should test:
//    * getting phase from a complex number
//    * creating a 3d rotation matrix and using it on an Nx3 array
//    * sine and arcsine
//    * modular arithmatic

int main() {
  int zero = 0;
  double fakePi = 3.0;

  double sinOfThing = 0.435;

  double answer1;

  answer1 = asin(sinOfThing);

  //  This is so gross.  Doesn't even have pi.  Boost does.  God. 
  //  This is so different.
  const double PI = atan(1.0)*4;

  cout << "zero is " << zero << endl;
  cout << "fakePi is " << fakePi << endl;

  cout << "sine of fake pi is " << sin(fakePi) << endl;
  cout << answer1 << endl;

  cout << endl;
  cout << endl;

  cout <<  "Testing modular arithmatic with fmod " << endl;
  cout << "I guess pi might be " << PI << endl;
  cout << "and 7 mod 2 pi might be " << (fmod(7.0,  (2*PI))) << endl;

  cout << endl;
  
  cout << "Testing getting the phase of a complex number " << endl;
  complex<double> xyPiOverFour (1.414, 1.414);
  cout << "The complex number is " << real(xyPiOverFour) <<
    " + " << imag(xyPiOverFour) << "j" << endl;
  cout << "With modulus " << abs(xyPiOverFour) << endl;
  cout << "and argument " << arg(xyPiOverFour) << endl;

  cout << endl;
  cout << endl;

  cout << "All that's left to test is to do this stuff to arrays, and to do an Nx3 times 3x3 array multiplication." << endl;
  cout << "And ... oh shit.  ... There's the issue of ... interpolation ....  " << endl;


  return(0);
}
