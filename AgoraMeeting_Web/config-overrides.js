const {
  override,
  useBabelRc,
  fixBabelImports,
  addWebpackModuleRule,
  addWebpackPlugin,
  disableEsLint,
  babelInclude,
  babelExclude,
  addBundleVisualizer,
  getBabelLoader,
  addWebpackAlias,
} = require('customize-cra')
const path = require('path')
const HardSourceWebpackPlugin = require('hard-source-webpack-plugin')
const SimpleProgressWebpackPlugin = require( 'simple-progress-webpack-plugin' )

// TODO: You can customize your env

const webWorkerConfig = () => config => {
  config.optimization = {
    ...config.optimization,
    noEmitOnErrors: false,
  }
  config.output = {
    ...config.output,
    globalObject: 'this'
  }
  return config
}

const sourceMap = () => config => {
  // TODO: Please use 'source-map' in production environment
  config.devtool = 'source-map'
  return config;
}

const useOptimizeBabelConfig = () => config => {
  const rule = {
    test: /\.(ts)x?$/i,
    include: [
      path.resolve("src")
    ],
    use: [
      'thread-loader', 'cache-loader', getBabelLoader(config).loader
    ],
    exclude: [
      path.resolve("node_modules"),
    ]
  }

  for (let _rule of config.module.rules) {
    if (_rule.oneOf) {
      _rule.oneOf.unshift(rule);
      break;
    }
  }
  console.log(JSON.stringify(config.extension))
  return config;
}

module.exports = override(
  useBabelRc(),
  disableEsLint(),
  webWorkerConfig(),
  sourceMap(),
  addWebpackModuleRule({
    test: /\.worker\.js$/,
    use: { loader: 'worker-loader' },
  }),
  fixBabelImports("import", [
    {
      libraryName: "@material-ui/core",
      libraryDirectory: "esm",
      camel2DashComponentName: false
    },
    {
      libraryName: "@material-ui/icon",
      libraryDirectory: "esm",
      camel2DashComponentName: false
    }
  ]),
  addWebpackPlugin(
    new SimpleProgressWebpackPlugin()
  ),
  babelInclude([
    path.resolve("src")
  ]),
  babelExclude([
    path.resolve("node_modules")
  ]),
  addWebpackPlugin(
    new HardSourceWebpackPlugin()
  ),
  addBundleVisualizer({
    // "analyzerMode": "static",
    // "reportFilename": "report.html"
  }, true),
  useOptimizeBabelConfig(),
  addWebpackAlias({
    ['@']: path.resolve(__dirname, 'src')
  })
)
