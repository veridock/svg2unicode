for svg in examples/*.svg; do
    echo -n "$svg: "
    ./scripts/svg2uchar "$svg"
done