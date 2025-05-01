const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

module.exports = (sequelize) => {

class Rule_penyakit extends Model {
  static associate(models) {
    // Asosiasi dengan model Gejala
    Rule_penyakit.belongsTo(models.Gejala, {
      foreignKey: 'id_gejala',
      as: 'gejala', // Nama asosiasi yang bisa digunakan saat melakukan query
    });

    // Asosiasi dengan model Penyakit
    Rule_penyakit.belongsTo(models.Penyakit, {
      foreignKey: 'id_penyakit',
      as: 'penyakit',
    });

  }
}

Rule_penyakit.init(
  {
    id_gejala: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'gejala', // Mengacu ke tabel 'gejala'
        key: 'id', // Mengacu ke kolom 'id' pada tabel 'gejala'
      },
    },
    nilai_pakar: {
      type: DataTypes.FLOAT,
      allowNull: false,
    },
    id_penyakit: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'penyakit', // Mengacu ke tabel 'penyakit'
        key: 'id', // Mengacu ke kolom 'id' pada tabel 'penyakit'
      },
    },
  },
  {
    sequelize,
    modelName: 'Rule_penyakit',
    tableName: 'rules_penyakit',
    timestamps: false,
    paranoid: false,
  }
);

return Rule_penyakit;

}
