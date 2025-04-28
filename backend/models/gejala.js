const { Model, DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  class Gejala extends Model {}

  Gejala.init(
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
    },
    {
      sequelize,
      modelName: 'Gejala',
      tableName: 'gejala',
      timestamps: false, // Jika ingin menggunakan createdAt & updatedAt, ubah ke true
      paranoid: false, // Jika menggunakan soft delete, ubah ke true
    }
  );

  return Gejala;  // Pastikan model dikembalikan dengan benar
};
