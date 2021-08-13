.PHONY: default build clean run build_release build_amd64_gnu_dynamic build_amd64_musl_static docker_build_ubuntu_amd64_dynamic docker_build_ubuntu_amd64_static docker_build_alpine_amd64_static docker_build_scratch_amd64_static build_amd64_gnu_dynamic_optimized build_amd64_musl_static_optimized docker_build_ubuntu_amd64_dynamic_optimized docker_build_ubuntu_amd64_static_optimized docker_build_alpine_amd64_static_optimized docker_build_scratch_amd64_static_optimized build_armv7_musl_static_optimized docker_build_scratch_armv7_static_optimized

gnu_target := x86_64-unknown-linux-gnu
musl_target := x86_64-unknown-linux-musl
arm32v7_target := armv7-unknown-linux-musleabihf

default: docker_build_ubuntu_amd64_dynamic_debug docker_build_ubuntu_amd64_dynamic docker_build_ubuntu_amd64_dynamic_optimized docker_build_ubuntu_amd64_static docker_build_ubuntu_amd64_static_optimized docker_build_alpine_amd64_static docker_build_alpine_amd64_static_optimized docker_build_scratch_amd64_static docker_build_scratch_amd64_static_optimized docker_build_scratch_armv7_static_optimized

build: build_release build_amd64_gnu_dynamic_debug build_amd64_gnu_dynamic build_amd64_gnu_dynamic_optimized build_amd64_musl_static build_amd64_musl_static_optimized build_armv7_musl_static_optimized

clean:
	cargo clean

run:
	cargo run

build_release:
	cargo build --release

build_amd64_gnu_dynamic_debug:
	cargo build --target $(gnu_target)

build_amd64_gnu_dynamic:
	cargo build --target $(gnu_target) --release

build_amd64_gnu_dynamic_optimized:
	cargo build --target $(gnu_target) --profile release-optimized -Z unstable-options

build_amd64_musl_static:
	cross build --target $(musl_target) --release

build_amd64_musl_static_optimized:
	cross build --target $(musl_target) --profile release-optimized -Z unstable-options

docker_build_ubuntu_amd64_dynamic_debug: build_amd64_gnu_dynamic_debug
	mkdir -p target/output
	cp target/$(gnu_target)/debug/minirust target/output/
	docker buildx build -f Dockerfile.ubuntu -t minirust:ubuntu_dynamic_debug --platform linux/amd64 .
	docker images minirust | grep -z ubuntu_dynamic_debug
	docker run --rm -ti minirust:ubuntu_dynamic_debug

docker_build_ubuntu_amd64_dynamic: build_amd64_gnu_dynamic
	mkdir -p target/output
	cp target/$(gnu_target)/release/minirust target/output/
	docker buildx build -f Dockerfile.ubuntu -t minirust:ubuntu_dynamic --platform linux/amd64 .
	docker images minirust | grep -z ubuntu_dynamic
	docker run --rm -ti minirust:ubuntu_dynamic

docker_build_ubuntu_amd64_dynamic_optimized: build_amd64_gnu_dynamic_optimized
	mkdir -p target/output
	cp target/$(gnu_target)/release-optimized/minirust target/output/
	docker buildx build -f Dockerfile.ubuntu -t minirust:ubuntu_dynamic_optimized --platform linux/amd64 .
	docker images minirust | grep -z ubuntu_dynamic_optimized
	docker run --rm -ti minirust:ubuntu_dynamic_optimized

docker_build_ubuntu_amd64_static: build_amd64_musl_static
	mkdir -p target/output
	cp target/$(musl_target)/release/minirust target/output/
	docker buildx build -f Dockerfile.ubuntu -t minirust:ubuntu_static --platform linux/amd64 .
	docker images minirust | grep -z ubuntu_static
	docker run --rm -ti minirust:ubuntu_static

docker_build_ubuntu_amd64_static_optimized: build_amd64_musl_static_optimized
	mkdir -p target/output
	cp target/$(musl_target)/release-optimized/minirust target/output/
	docker buildx build -f Dockerfile.ubuntu -t minirust:ubuntu_static_optimized --platform linux/amd64 .
	docker images minirust | grep -z ubuntu_static_optimized
	docker run --rm -ti minirust:ubuntu_static_optimized

docker_build_alpine_amd64_static: build_amd64_musl_static
	mkdir -p target/output
	cp target/$(musl_target)/release/minirust target/output/
	docker buildx build -f Dockerfile.alpine -t minirust:alpine_static --platform linux/amd64 .
	docker images minirust | grep -z alpine_static
	docker run --rm -ti minirust:alpine_static

docker_build_alpine_amd64_static_optimized: build_amd64_musl_static_optimized
	mkdir -p target/output
	cp target/$(musl_target)/release-optimized/minirust target/output/
	docker buildx build -f Dockerfile.alpine -t minirust:alpine_static_optimized --platform linux/amd64 .
	docker images minirust | grep -z alpine_static_optimized
	docker run --rm -ti minirust:alpine_static_optimized

docker_build_scratch_amd64_static: build_amd64_musl_static
	mkdir -p target/output
	cp target/$(musl_target)/release/minirust target/output/
	docker buildx build -f Dockerfile -t minirust:scratch --platform linux/amd64 .
	docker images minirust | grep -z scratch
	docker run --rm -ti minirust:scratch

docker_build_scratch_amd64_static_optimized: build_amd64_musl_static_optimized
	mkdir -p target/output
	cp target/$(musl_target)/release-optimized/minirust target/output/
	docker buildx build -f Dockerfile -t minirust:scratch_optimized --platform linux/amd64 .
	docker images minirust | grep -z scratch_optimized
	docker run --rm -ti minirust:scratch_optimized

build_armv7_musl_static_optimized:
	cross build --target $(arm32v7_target) --profile release-optimized -Z unstable-options

docker_build_scratch_armv7_static_optimized: build_armv7_musl_static_optimized
	mkdir -p target/output
	cp target/$(arm32v7_target)/release-optimized/minirust target/output/
	docker buildx build -f Dockerfile -t minirust:scratch_arm32v7 --platform linux/arm/v7 .
	docker images minirust | grep -z scratch_arm32v7
