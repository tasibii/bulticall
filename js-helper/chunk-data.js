const fs = require("fs");

function chunk(array, size) {
  const chunked = [];
  let chunk = [];
  array.forEach((item) => {
    if (chunk.length === size) {
      chunked.push(chunk);
      chunk = [item];
    } else {
      chunk.push(item);
    }
  });

  if (chunk.length) {
    chunked.push(chunk);
  }

  return chunked;
}

function uniqueArray(inputArray) {
  const uniqueSet = new Set(inputArray);
  return [...uniqueSet];
}

function main(path, size) {
  const data = fs.readFileSync(path, "utf-8");
  const array = data.split(/\r?\n/);
  const cleanArray = uniqueArray(array);
  const chunked = chunk(cleanArray, size);
  let i = 0;
  chunked.forEach((item) => {
    fs.writeFileSync(
      `./js-helper/data/${i * size + 1}~${i * size + size}.txt`,
      "[" + item.toString() + "]"
    );
    ++i;
  });
}

main("./js-helper/data.dt", 300);
