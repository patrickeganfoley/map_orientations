/*  This is just going to show an image. */
#define cimg_use_jpeg
#include "CImg-1.5.1/CImg.h"
using namespace cimg_library;

int main(argc, char **argv) {

  const char* file = cimg_option(
				 "-f",
				 cimg_imagepath "parrot_original.ppm",
				 "path and file name");

  CImg<unsigned char> src(file);

  CImgDisplay dispImage(src, "The Image");

  return(0);


}
