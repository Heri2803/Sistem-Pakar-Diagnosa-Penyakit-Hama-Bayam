'use strict';
const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  class Histori extends Model {
    static associate(models) {
      // Relasi ke User
      Histori.belongsTo(models.User, {
        foreignKey: 'userId',
        as: 'user'
      });

      // Relasi ke Gejala (satu gejala per baris)
      Histori.belongsTo(models.Gejala, {
        foreignKey: 'id_gejala',
        as: 'gejala'
      });

      // Relasi ke Penyakit (opsional)
      Histori.belongsTo(models.Penyakit, {
        foreignKey: 'id_penyakit',
        as: 'penyakit'
      });

      // Relasi ke Hama (opsional)
      Histori.belongsTo(models.Hama, {
        foreignKey: 'id_hama',
        as: 'hama'
      });
    }
  }

  Histori.init({
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    id_gejala: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    id_penyakit: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    id_hama: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    tanggal_diagnosa: {
      type: DataTypes.DATE,
      allowNull: false
    },
    hasil: {
      type: DataTypes.FLOAT,
      allowNull: false
    }
  }, {
    sequelize,
    modelName: 'Histori',
    tableName: 'histori',
    timestamps: false // kalau kamu pakai kolom createdAt & updatedAt
  });

  return Histori;
};
