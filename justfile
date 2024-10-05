@default:
    just --list

@run *args:
    crystal run src/main.cr --error-trace -- {{args}}

@build:
    crystal build src/main.cr --release -o build/soop

@install-tool: build
    cp ./build/soop ~/tools
