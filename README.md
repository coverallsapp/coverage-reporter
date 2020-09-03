# Coveralls Universal Coverage Reporter

To get started you will need crystal [installed](https://crystal-lang.org/install/) on your machine and then you can run
```
shards install
crystal build src/cli.cr
```

Self-contained Linux binary compiling:
```bash
docker run --rm -it -v $PWD:/app -w /app crystallang/crystal:latest-alpine crystal build src/cli.cr -o cli --release --static --no-debug
```