@default:
    just --list

@run *args:
    crystal run src/main.cr --error-trace --link-flags -L/usr/lib -- {{args}}

@build:
    crystal build src/main.cr --release  --link-flags -L/usr/lib -o build/soop

@install-tool install_path="~/tools": build
    cp ./build/soop {{install_path}}
    cp -r templates/ ~/.config/soop/templates
