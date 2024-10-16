const defaultTheme = require('tailwindcss/defaultTheme')

// in development we use tailwind CDN so don't need to recompile
// on each request
module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim,.html.erb}'
  ],
  theme: {
    extend: {
    },
  },
  //corePlugins: {
    //preflight: false,
  //},
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
