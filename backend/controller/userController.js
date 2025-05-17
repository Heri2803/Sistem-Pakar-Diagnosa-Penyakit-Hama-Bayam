const {User} = require('../models');
const argon2 = require('argon2');
const { Op } = require('sequelize');

// Menampilkan semua user
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.findAll({ attributes: { exclude: ['password'] } });
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving users', error });
  }
};

// Menampilkan satu user berdasarkan ID
exports.getUserById = async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id, { attributes: { exclude: ['password'] } });
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving user', error });
  }
};

// Menambahkan user baru dengan hashing Argon2
exports.createUser = async (req, res) => {
  try {
    const { name, email, password, alamat, nomorTelepon, role } = req.body;

    // Cek apakah email sudah terdaftar
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) return res.status(400).json({ message: 'Email already exists' });

    // Hash password menggunakan Argon2
    const hashedPassword = await argon2.hash(password);

    const newUser = await User.create({
      name,
      email,
      password: hashedPassword,
      alamat,
      nomorTelepon,
      role
    });

    res.status(201).json({ message: 'User created successfully', user: newUser });
  } catch (error) {
    res.status(500).json({ message: 'Error creating user', error });
  }
};

// Mengupdate user berdasarkan ID
exports.updateUser = async (req, res) => {
  try {
    const { name, email, alamat, nomorTelepon, role } = req.body;

    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    await user.update({ name, email, alamat, nomorTelepon, role });

    res.status(200).json({ message: 'User updated successfully', user });
  } catch (error) {
    res.status(500).json({ message: 'Error updating user', error });
  }
};

// Mengupdate berdasarkan ID
exports.updateUserEmail = async (req, res) => {
  try {
      const { id } = req.params;
      const { name, email, alamat, nomorTelepon, password } = req.body;
  
      if (!id) {
        return res.status(400).json({ message: "ID harus disertakan" });
      }
  
      const user = await User.findByPk(id);
  
      if (!user) {
        return res.status(404).json({ message: "User tidak ditemukan" });
      }

      // Check email uniqueness
      if (email && email !== user.email) {
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
          return res.status(400).json({ message: "Email sudah digunakan" });
        }
      }
  
      // Hash password if provided
      let hashedPassword = user.password;
      if (password) {
        hashedPassword = await argon2.hash(password);
      }
  
      await user.update({
        name: name || user.name,
        email: email || user.email,
        alamat: alamat || user.alamat,
        nomorTelepon: nomorTelepon || user.nomorTelepon,
        password: hashedPassword,
      });
  
      // Updated response object
      const userResponse = {
        id: user.id,
        name: user.name,
        email: user.email,
        alamat: user.alamat,
        nomorTelepon: user.nomorTelepon,
        role: user.role,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        passwordUpdated: Boolean(password) // Menggunakan Boolean untuk mengkonversi ke true/false
      };
  
      res.status(200).json({ 
        message: "User berhasil diperbarui", 
        user: userResponse 
      });

    } catch (error) {
      console.error('Update user error:', error);
      res.status(500).json({ 
        message: "Terjadi kesalahan pada server", 
        error: error.message 
      });
    }
};

// Menghapus user berdasarkan ID (soft delete)
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    await user.destroy();
    res.status(200).json({ message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting user', error });
  }
};

// Mengembalikan user yang telah dihapus (restore soft delete)
exports.restoreUser = async (req, res) => {
  try {
    const user = await User.findOne({
      where: { id: req.params.id },
      paranoid: false,
    });

    if (!user) return res.status(404).json({ message: 'User not found' });

    await user.restore();
    res.status(200).json({ message: 'User restored successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error restoring user', error });
  }
};

// Verifikasi password dengan Argon2
exports.verifyPassword = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Cari user berdasarkan email
    const user = await User.findOne({ where: { email } });
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Verifikasi password
    const validPassword = await argon2.verify(user.password, password);
    if (!validPassword) return res.status(400).json({ message: 'Invalid password' });

    res.status(200).json({ message: 'Login successful' });
  } catch (error) {
    res.status(500).json({ message: 'Error verifying password', error });
  }
};
