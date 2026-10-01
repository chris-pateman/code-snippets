
$path_to_code = "./pateman.workspace\code-repos\version1\tf-az-lz-spokes"

docker run -e LOG_LEVEL=DEBUG  -e RUN_LOCAL=true  -v $path_to_code`:/tmp/lint  ghcr.io/super-linter/super-linter:latest