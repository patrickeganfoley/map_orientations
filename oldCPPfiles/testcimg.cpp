#include <iostream>
#include "CImg-1.5.1/CImg.h"

using namespace std;
using namespace cimg_library;

int main() {

  cout << "I'm now going to be using the Cimg library instead of boost::gil." << endl;
  cout << "It seems as though Cimg is a far more serious project, and is very well supported, active, and more extensible to other projects." << endl;
  cout << "Boost seems cooler in general, but it isn't really about image processing.  Cimg seems like the boss." << endl;

  CImg<unsigned char> image("peters-political2.jpg"), visu(500,400,1,3,0);
  const unsigned char red[] = {255, 0, 0}, green[] = {0, 255, 0}, blue[] = {0, 0, 255};
  image.blur(2.5);
  CImgDisplay main_disp(image, "Click a point"), draw_disp(visu, "Intensity profile");
  while (!main_disp.is_closed() && !draw_disp.is_closed()) {
    main_disp.wait();
    if (main_disp.button() && main_disp.mouse_y()>=0) {
      const int y = main_disp.mouse_y();
      visu.fill(0).draw_graph(image.get_crop(0, y, 0, 0, image.width() - 1, y, 0, 0), red, 1, 1, 0, 255, 0);
      visu.draw_graph(image.get_crop(0, y, 0, 1, image.width() - 1, y, 0, 1), green, 1, 1, 0, 255, 0);
      visu.draw_graph(image.get_crop(0, y, 0, 2, image.width() -1 , y, 0, 2), blue, 1, 1, 0, 255, 0).display(draw_disp);
    }
  }

  return(0);

}