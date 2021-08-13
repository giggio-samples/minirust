# Rust FROM scratch

This repo shows examples on how to build a small container with a Rust application.
The demos were presented at a talk in Portuguese. The details of the talk are
[here](https://bit.ly/rustfromscratch).

## Running

There is a Makefile at the root, there you will find what you need to run. This is
what you need to build and run everything.

````bash
make
````

At the end the results with be at the `target` folder and the images will be names
`minirust:sometag`.

## Author

[Giovanni Bassi](https://github.com/giggio)

## License

Licensed under the MIT.
