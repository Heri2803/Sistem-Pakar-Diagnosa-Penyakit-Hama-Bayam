// const { Sequelize } = require('sequelize');
// require('dotenv').config();

// const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASSWORD, {
//     host: process.env.DB_HOST,
//     dialect: 'mysql',
//     timezone: '+07:00',
// });

// module.exports = sequelize;

const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT, // tambahkan port
    dialect: 'mysql',
    dialectModule: require('mysql2'),
    timezone: '+07:00',
    dialectOptions: {
      ssl: {
        rejectUnauthorized: false, // jika diperlukan (tergantung Clever Cloud)
      }
    }
  }
);

module.exports = sequelize;
