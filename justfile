serve:
    gleam run -m lustre/dev start

build:
    cp -r priv ./dist/
    gleam run -m lustre/dev build --minify --outdir=dist

clean:
    rm -rf dist
