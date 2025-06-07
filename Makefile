all :: test

test ::
	bash -n zigup.sh
#	shellcheck zigup.sh

docker-test ::
	docker run --rm -i -v "$(PWD):/mnt" koalaman/shellcheck:stable zigup.sh
