all: build_locust_image


build_locust_image:
	docker build -t lnplocust:v1 .
