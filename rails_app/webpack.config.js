// output.pathに絶対パスを指定する必要があるため、pathモジュールを読み込んでおく
const path = require('path');
const glob = require('glob');
const webpack = require('webpack');
const VueLoaderPlugin = require('vue-loader/lib/plugin');
const ManifestPlugin = require('webpack-manifest-plugin');
//const MiniCssExtractPlugin = require('mini-css-extract-plugin')

// 環境変数を使う
// https://cloudpack.media/31949
if (process.env.NODE_ENV === 'production') {
  var myMode = "production";
  var myTool = "";
}else{
  var myMode = "development";
  var myTool = 'eval-source-map' /*'cheap-module-eval-source-map'*/;
}
console.log("mode: ", myMode);


// 入力Path
const srcRoot = path.resolve(__dirname, 'vue');
const jsPath = srcRoot + "/" + 'javascripts/*.js';
const imgPath = srcRoot + "/" + 'images';
// 出力Path
const outputRoot = path.resolve(__dirname, 'public');
const jsOutPath = 'javascripts';
const imgOutPath = 'images';


module.exports = {
  // モードの設定: develop or production
  mode: myMode,
  // ビルド対象のディレクトリを設定
  entry: getAllJavaScriptFiles(jsPath),

  output: {
    path: outputRoot,
    filename: jsOutPath + '/' + '[name]-[hash].js'
  },
  plugins: [
    new ManifestPlugin({
      fileName: 'manifest.json',
      //publicPath: '/',
      writeToFileEmit: true
    }),
    new VueLoaderPlugin(),
    new webpack.HotModuleReplacementPlugin(),
  ],
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader',
        options: {
          loaders: {
            // .vueの内部で、<style scoped lang="scss">と宣言すること
            scss: 'vue-style-loader!css-loader!sass-loader',
          }
        }
      },
      {
        test: /\.scss$/,
        use:[
          'style-loader',
          'css-loader',
          'sass-loader'
        ]
      },
      {   // image
        test: /\.(png|jpg|gif|svg)$/,
        include: imgPath,
        loader: 'file-loader',
        options: {
            name: '[name].[ext]',
            // 出力先パス = 変数"outputRoot"からの相対パス
            outputPath: imgOutPath, 
            // 出力ファイルから見た相対パス(現在無効)
            //publicPath: path => imgOutPath + '/' + path,
        }
    }
    ],
  },
  devtool: myTool,
  devServer: {
    //
    // ハマりどころ --> docker-composeで 3035ポートを解放すること
    //
    //host: 'localhost',
    port: 3035,
    publicPath: 'http://localhost:3035/',
    contentBase: outputRoot,
    // hot: true,
    // disableHostCheck: true,
    // historyApiFallback: true,
    // headers: {
    //   'Access-Control-Allow-Origin': '*',
    //   'Access-Control-Allow-Headers': '*'
    // }
  }
};

// helper
function getAllJavaScriptFiles(pathQuery){
  let entries = {}
  glob.sync(pathQuery).map(function(file) {
    console.log("loaded file: " + file.split('/').slice(-1)[0]);
    let name = file.split('/').slice(-1)[0].split('.')[0]
    entries[name] = file
  });
  return entries;
}

