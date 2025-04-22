# image_key_generator

A Flutter project for an Android app, which generates a key for encrypted traffic using a image or the difference between two images.

This is a proof of concept app developed alongside my paper analysing the entropy of images and how to utilize them for key generation (released soon™️)

## Documentation and usage

Documentation of the app will be done once the paper has been published.

## Used dependencies

- camera
- image
- crypto
- pointycastle

## Things to do

- [x] Take multiple pictures
- [x] Calculate the difference of two images
- [x] Calculate the entropy of the difference
- [x] Allow the user to choose, which picture he wants to use to generate the key
- [X] Generate the key using a picture
- [ ] Allow multiple key choices