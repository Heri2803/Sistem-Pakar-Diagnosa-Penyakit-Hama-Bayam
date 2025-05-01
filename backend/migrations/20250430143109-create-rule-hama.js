'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('Rules_hama', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      id_gejala: {
        type: Sequelize.INTEGER,
        references: {
          model: 'gejala',
          key: 'id'
        }
      },
      nilai_pakar: {
        type: Sequelize.FLOAT
      },
      id_hama: {
        type: Sequelize.INTEGER,
        references: {
          model: 'hama',  
          key: 'id'
        }
      },
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('Rules_hama');
  }
};