#include "CImg-1.5.1/CImg.h"

using namespace cimg_library;

int main() {

  CImg<unsigned char> image("peters-political2.jpg");
  const unsigned char color[] = {255, 128, 64};

  image.draw_rectangle(200, 30, 300, 100, color, 0.5);
  image.save_png("/tmp/result_image.png");
  //  image.draw();
}
