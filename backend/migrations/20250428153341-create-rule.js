'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('Rules_penyakit', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      id_gejala: {
        type: Sequelize.INTEGER,
        references:{
          model: 'gejala',
          key: 'id'
        }
      },
      nilai_pakar: {
        type: Sequelize.FLOAT,
        allowNull: false
      },
      id_penyakit: {
        type: Sequelize.INTEGER,
        references:{
          model: 'penyakit',
          key:'id'
        }
      },
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('Rules_penyakit');
  }
};