const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

module.exports = (sequelize) => {
  class Hama extends Model {}

  Hama.init(
    {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: DataTypes.INTEGER,
      },
      kode: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      nama: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      deskripsi: {
        type: DataTypes.STRING,
        allowNull: true,
      },
      penanganan: {
        type: DataTypes.STRING,
        allowNull: true,
      },
      foto: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      nilai_pakar: {
        type: DataTypes.FLOAT,
        allowNull: true
      }
    },
    {
      sequelize,
      modelName: 'Hama',
      tableName: 'hama',
      timestamps: false, // Jika ingin menggunakan createdAt & updatedAt, ubah ke true
      paranoid: false, // Jika menggunakan soft delete, ubah ke true
    }
  );
  return Hama;
}