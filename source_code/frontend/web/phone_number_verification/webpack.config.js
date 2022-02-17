const path = require("path");
const ClosurePlugin = require("closure-webpack-plugin");

module.exports = {
  // The entry point file described above
  entry: "./src/verify_phone_number.js",
  // The location of the build folder described above
  output: {
    path: path.resolve(__dirname, "dist"),
    filename: "verify_phone_number.js",
  },
  // Optional and for development only. This provides the ability to
  // map the built code back to the original source format when debugging.
  devtool: "eval-source-map",
  optimization: {
    minimizer: [new ClosurePlugin({ mode: "STANDARD" }, {})],
  },
};
