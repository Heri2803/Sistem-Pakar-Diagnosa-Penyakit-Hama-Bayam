const jwt = require('jsonwebtoken');
const argon2 = require('argon2');
const randomstring = require('randomstring');
const  User  = require('../models/user'); // Pastikan sesuai dengan struktur project
require('dotenv').config();

// Fungsi untuk membuat token JWT
const generateToken = (user) => {
    return jwt.sign(
        { id: user.id, email: user.email, role: user.role }, // id bukan _id untuk Sequelize
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
    );
};


// Menambahkan user baru dengan hashing Argon2
exports.register = async (req, res) => {
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
        role: 'user'
      });
  
      res.status(201).json({ message: 'User created successfully', user: newUser });
    } catch (error) {
      res.status(500).json({ message: 'Error creating user', error });
    }
  };
  

// Login
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // 🔹 Cek apakah user dengan email tersebut ada
        const user = await User.findOne({ where: { email } });
        if (!user) {
            return res.status(401).json({ message: "Email atau password salah" });
        }

        // 🔹 Verifikasi password
        const isPasswordValid = await argon2.verify(user.password, password);
        if (!isPasswordValid) {
            return res.status(401).json({ message: "Email atau password salah" });
        }

        // 🔹 Buat token JWT
        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role }, 
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
        );

        // 🔹 Kirim response dengan token dan role
        res.status(200).json({
            message: "Login berhasil",
            token,
            role: user.role  // Ini penting untuk Flutter agar bisa menentukan halaman tujuan
        });
    } catch (error) {
        res.status(500).json({ message: "Terjadi kesalahan", error });
    }
};

exports.forgotPassword = async (req, res) => {
    try {
        const { email, password } = req.body;  // Gunakan 'password' sebagai field yang dikirim

        // 🔹 Validasi input
        if (!email || !password) {
            return res.status(400).json({ message: "Email dan password baru harus diisi" });
        }

        // 🔹 Cek apakah user dengan email tersebut ada
        const user = await User.findOne({ where: { email } });
        if (!user) {
            return res.status(404).json({ message: "User tidak ditemukan" });
        }

        // 🔹 Hash password baru dengan Argon2
        const hashedPassword = await argon2.hash(password);

        // 🔹 Update password user di database
        await user.update({ password: hashedPassword });

        res.status(200).json({ message: "Password berhasil diperbarui" });
    } catch (error) {
        console.error("Error pada forgotPassword:", error);
        res.status(500).json({ message: "Terjadi kesalahan", error: error.message });
    }
};
