'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('histori', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      userId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'users', // sesuaikan dengan nama tabel Users kamu
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      id_gejala: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'gejala', // sesuaikan dengan nama tabel Gejalas kamu
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      id_penyakit: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'penyakit',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      id_hama: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'hama',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      tanggal_diagnosa: {
        type: Sequelize.DATE,
        allowNull: false
      },
      hasil: {
        type: Sequelize.FLOAT,
        allowNull: false
      },
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('histori');
  }
};
