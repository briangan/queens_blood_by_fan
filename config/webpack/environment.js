const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

// Provide jQuery and BestInPlaceEditor globally
environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  'window.jQuery': 'jquery'
}))

module.exports = environment
