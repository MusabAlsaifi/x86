#include <stdio.h>
#include <stdlib.h>

extern void fadecircle(
  unsigned char* image, 
  int width, int height, 
  int xc, int yc, 
  int radius, 
  unsigned int color
);

int getOffset(unsigned char* image) {
  if (!image) {
    fprintf(stderr, "Null pointer error in getOffset\n");
    exit(EXIT_FAILURE);
  }
  return (*((int*)(image + 0x0A)));
}

int getWidth(unsigned char* image) {
  if (!image) {
    fprintf(stderr, "Null pointer error in getWidth\n");
    exit(EXIT_FAILURE);
  }
  return *((int*)(image + 0x12));
}

int getHeight(unsigned char* image) {
  if (!image) {
    fprintf(stderr, "Null pointer error in getHeight\n");
    exit(EXIT_FAILURE);
  }
  return *((int*)(image + 0x16));
}

size_t getSize(FILE* hFile) {
  fseek(hFile, 0, SEEK_END);
  size_t size = ftell(hFile);
  rewind(hFile);
  return size;
}

// Read an unsigned integer from user input
unsigned int readInt32(const char* msg) {
    unsigned int result;
    printf("%s", msg);
    if (scanf("%u", &result) != 1) {
        fprintf(stderr, "Error reading integer\n");
        exit(EXIT_FAILURE);
    }
    return result;
}

int main(int argc, char** argv)
{
    size_t image_size = 0;
    unsigned char* image = NULL;

    // Check the command-line arguments
    if (argc != 3) {
        fprintf(stderr, "Usage: %s [input.bmp] [output.bmp]\n", argv[0]);
        return EXIT_FAILURE;
    }

    // Open the input file
    FILE* hFile = fopen(argv[1], "rb");
    if (!hFile) {
        perror("Error opening the input file");
        return EXIT_FAILURE;
    }

    image_size = getSize(hFile);  // Get the size of the input file

    // Allocate memory for the image data
    image = (unsigned char*)malloc(image_size);
    if (!image) {
        fprintf(stderr, "Memory allocation failed\n");
        fclose(hFile);
        return EXIT_FAILURE;
    }

    // Read the image data from the input file
    if (fread(image, image_size, 1, hFile) != 1) {
        fprintf(stderr, "Error reading the input file\n");
        free(image);
        fclose(hFile);
        return EXIT_FAILURE;
    }
    fclose(hFile);

    int xc, yc;
    printf("X-Center: ");
    if (scanf("%i", &xc) != 1) {
        fprintf(stderr, "Error reading X-Center\n");
        free(image);
        return EXIT_FAILURE;
    }

    printf("Y-Center: ");
    if (scanf("%i", &yc) != 1) {
        fprintf(stderr, "Error reading Y-Center\n");
        free(image);
        return EXIT_FAILURE;
    }

    int radius;
    printf("Radius: ");
    if (scanf("%i", &radius) != 1) {
        fprintf(stderr, "Error reading Radius\n");
        free(image);
        return EXIT_FAILURE;
    }

    unsigned int color = 0;
    color |= readInt32("R: ");          //read Red value
    color |= readInt32("G: ") << 8;     //read Green value and shift by 8
    color |= readInt32("B: ") << 16;    //read Blue value and shift by 16

  // Get image offset, width, and height
  int offset = getOffset(image);
  int width = getWidth(image);
  int height = getHeight(image);

    fadecircle(image + offset, width, height, xc, yc, radius, color);

    // Open the output file
    hFile = fopen(argv[2], "wb");
    if (!hFile) {
        perror("Error opening the output file");
        free(image);
        return EXIT_FAILURE;
    }

    // Write the modified image data to the output file
    if (fwrite(image, image_size, 1, hFile) != 1) {
        fprintf(stderr, "Error writing to the output file\n");
        free(image);
        fclose(hFile);
        return EXIT_FAILURE;
    }

    fclose(hFile);
    free(image);

    return EXIT_SUCCESS;
}