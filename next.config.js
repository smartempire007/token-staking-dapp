/** @type {import('next').NextConfig} */
if (process.env.NODE_ENV === 'development') {
  require('dotenv').config()
}
const nextConfig = {
  reactStrictMode: true,
}

//module.exports = nextConfig

module.exports = nextConfig, {
  env: {
    BASE_URL: process.env.BASE_URL,
  }
}