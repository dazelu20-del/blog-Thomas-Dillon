const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const dist = path.join(root, "dist");

const copyPaths = ["index.html", "post.html", "css", "js", "images"];

if (fs.existsSync(dist)) {
  fs.rmSync(dist, { recursive: true, force: true });
}
fs.mkdirSync(dist, { recursive: true });

for (const item of copyPaths) {
  const src = path.join(root, item);
  const dest = path.join(dist, item);
  fs.cpSync(src, dest, { recursive: true });
}

console.log("Built dist/ for deployment");
