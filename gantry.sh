#!/bin/bash

# Copyright (c) 2022, Matthias Kruk

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

make_image() {
	local user="$1"
	local image="$2"
	local version="$3"
	local distro="$4"

	local output

	if ! output=$(sudo stuffer --name "$user/$image" \
	                           --version "$version"  \
	                           --distro "$distro" 2>&1); then
		log_error "Image generation failed"
		log_highlight "stuffer output" <<< "$output" | log_error
		return 1
	fi

	return 0
}

push_image() {
	local user="$1"
	local image="$2"
	local version="$3"

	local output

	if ! output=$(docker push "$user/$image:$version" 2>&1); then
		log_error "Failed to push image to hub.docker.com"
		log_highlight "docker push output" <<< "$output" | log_error
		return 1
	fi

	return 0
}

make_and_push() {
	local user="$1"
	local tag="$2"
	local distro="$3"

	local image
	local version

	image="${tag%%:*}"
	version="${tag##*:}"

	if ! make_image "$user" "$image" "$version" "$distro"; then
		return 1
	fi

	if ! push_image "$user" "$image" "$version"; then
		return 1
	fi

	return 0
}

main() {
	local user
	local tag
	local distro

	opt_add_arg "u" "user"       "rv" "" "hub.docker.com username"
	opt_add_arg "t" "tag"        "rv" "" "Tag of the image"            '^[^:]+:.+$'
	opt_add_arg "d" "distro"     "rv" "" "Distro of the new image"

	if ! opt_parse "$@"; then
		return 1
	fi

	user=$(opt_get "user")
	tag=$(opt_get "tag")
	distro=$(opt_get "distro")

	if ! make_and_push "$user" "$tag" "$distro"; then
		return 1
	fi

	return 0
}

{
	if ! . toolbox.sh ||
	   ! include "log" "opt"; then
		exit 1
	fi

	main "$@"
	exit "$?"
}
