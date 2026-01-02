all: build
	@cmake --build build
	@cp build/main.com .

build: CMakeLists.txt support/CMakeLists.txt src/CMakeLists.txt
	@cmake -S . -B build --fresh

clean:
	@rm -rf build
	@rm -f main.com

.PHONY: all clean
