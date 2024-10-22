const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim,.html.erb}',
    './app/assets/stylesheets/application.tailwind.css'
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
