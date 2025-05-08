const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

module.exports = (sequelize) => {

class Rule_hama extends Model {
  static associate(models) {
    // Asosiasi dengan model Gejala
    Rule_hama.belongsTo(models.Gejala, {
      foreignKey: 'id_gejala',
      as: 'gejala', // Nama asosiasi yang bisa digunakan saat melakukan query
    });

    // Asosiasi dengan model hama
    Rule_hama.belongsTo(models.Hama, {
      foreignKey: 'id_hama',
      as: 'hama',
    }); 
  }
}

Rule_hama.init(
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
    id_hama: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'hama', 
        key: 'id', 
      },
    },
  },
  {
    sequelize,
    modelName: 'Rule_hama',
    tableName: 'rules_hama',
    timestamps: false,
    paranoid: false,
  }
);

return Rule_hama;

}
