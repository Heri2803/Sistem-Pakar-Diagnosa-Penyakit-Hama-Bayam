const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

module.exports =(sequelize) => {  
  class Penyakit extends Model {}

    Penyakit.init(
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
        }
      },
      {
        sequelize,
        modelName: 'Penyakit',
        tableName: 'penyakit',
        timestamps: false, // Jika ingin menggunakan createdAt & updatedAt, ubah ke true
        paranoid: false, // Jika menggunakan soft delete, ubah ke true
      }
    );
    
    return Penyakit;
  }