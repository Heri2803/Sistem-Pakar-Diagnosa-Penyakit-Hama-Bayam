'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('hamas', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      kode: {
        type: Sequelize.STRING,
        allowNull: true
        
      },
      nama: {
        type: Sequelize.STRING,
        allowNull: true
      },
      deskripsi: {
        type: Sequelize.STRING
      },
      penanganan: {
        type: Sequelize.STRING,
        allowNull: true
      },
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('hamas');
  }
};