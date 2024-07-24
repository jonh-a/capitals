const path = require('path');

module.exports = {
  entry: './build/dev/javascript/capitals/priv/static/capitals.mjs',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist'),
  },
  mode: 'production'
};
