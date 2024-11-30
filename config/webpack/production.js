process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
const config = environment.toWebpackConfig()

// Fix node configuration
config.node = {
  __dirname: true,
  __filename: true,
  global: true
}

// Remove problematic plugins
config.plugins = config.plugins.filter(plugin => {
  const name = plugin.constructor.name
  return !['CompressionPlugin', 'TerserPlugin'].includes(name)
})

// Disable optimization
config.optimization = {
  minimize: false
}

module.exports = config
