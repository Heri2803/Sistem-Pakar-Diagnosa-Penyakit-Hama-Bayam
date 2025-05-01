const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/database');

module.exports = (sequelize) => {
  class User extends Model {}

      User.init(
        {
          id: {
            allowNull: false,
            autoIncrement: true,
            primaryKey: true,
            type: DataTypes.INTEGER,
          },
          name: {
            type: DataTypes.STRING,
            allowNull: true,
          },
          email: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
            validate: {
              isEmail: true,
            },
          },
          password: {
            type: DataTypes.STRING,
            allowNull: false,
          },
          alamat: {
            type: DataTypes.STRING,
            allowNull: true,
          },
          nomorTelepon: {
            type: DataTypes.STRING,
            allowNull: true,
          },
          role: {
            type: DataTypes.STRING,
            allowNull: false,
          },
        },
        {
          sequelize,
          modelName: 'User',
          tableName: 'users',
          timestamps: false, // Pastikan timestamps aktif jika menggunakan paranoid
          paranoid: false, // Hanya gunakan ini jika timestamps: true
        
        }
      );
      return User;
}
