const { Model, DataTypes } = require('sequelize');


module.exports = (sequelize) => {

class Rule extends Model {
  static associate(models) {
    // Asosiasi dengan model Gejala
    Rule.belongsTo(models.Gejala, {
      foreignKey: 'id_gejala',
      as: 'gejala', // Nama asosiasi yang bisa digunakan saat melakukan query
    });

    // Asosiasi dengan model Penyakit
    Rule.belongsTo(models.Penyakit, {
      foreignKey: 'id_penyakit',
      as: 'penyakit',
    });

    // Asosiasi dengan model Hama
    Rule.belongsTo(models.Hama, {
      foreignKey: 'id_hama',
      as: 'hama',
    });
  }
}

Rule.init(
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
    id_hama: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'hama', // Mengacu ke tabel 'hama'
        key: 'id', // Mengacu ke kolom 'id' pada tabel 'hama'
      },
    },
  },
  {
    sequelize,
    modelName: 'Rule',
    tableName: 'rules',
    timestamps: false,
    paranoid: false,
  }
);

return Rule;

}
