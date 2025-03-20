const express = require('express');
const router = express.Router();
const userController = require('../controller/userController');

/**
 * @swagger
 * tags:
 *   name: Users
 *   description: API untuk mengelola pengguna
 */

/**
 * @swagger
 * /api/users:
 *   post:
 *     summary: Membuat pengguna baru
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - password
 *             properties:
 *               name:
 *                 type: string
 *                 description: Nama pengguna
 *               email:
 *                 type: string
 *                 description: Email pengguna (harus unik)
 *               password:
 *                 type: string
 *                 description: Password pengguna
 *               alamat:
 *                 type: string
 *                 description: Alamat pengguna (opsional)
 *               nomorTelepon:
 *                 type: string
 *                 description: Nomor telepon pengguna (opsional)
 *               role:
 *                 type: string
 *                 description: Nomor telepon pengguna (opsional)
 *     responses:
 *       201:
 *         description: User berhasil dibuat
 *       400:
 *         description: Email sudah digunakan
 *       500:
 *         description: Terjadi kesalahan pada server
 */
router.post('/', userController.createUser);

/**
 * @swagger
 * /api/users:
 *   get:
 *     summary: Mendapatkan semua data user
 *     tags: [Users]
 *     responses:
 *       200:
 *         description: Data user berhasil diambil
 *       500:
 *         description: Terjadi kesalahan pada server
 */
router.get('/', userController.getAllUsers);

/**
 * @swagger
 * /api/users/{id}:
 *   get:
 *     summary: Mendapatkan user berdasarkan ID
 *     tags: [Users]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID pengguna
 *     responses:
 *       200:
 *         description: Data user berhasil ditemukan
 *       404:
 *         description: User tidak ditemukan
 *       500:
 *         description: Terjadi kesalahan pada server
 */
router.get('/:id', userController.getUserById);

/**
 * @swagger
 * /api/users:
 *   put:
 *     summary: Mengupdate data user berdasarkan email
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 description: Email pengguna (digunakan untuk mencari user)
 *               name:
 *                 type: string
 *               alamat:
 *                 type: string
 *               nomorTelepon:
 *                 type: string
 *               newPassword:
 *                 type: string
 *                 description: Password baru (opsional)
 *     responses:
 *       200:
 *         description: User berhasil diperbarui
 *       404:
 *         description: User tidak ditemukan
 *       500:
 *         description: Terjadi kesalahan pada server
 */
router.put('/', userController.updateUserEmail);

/**
 * @swagger
 * /api/users/{id}:
 *   delete:
 *     summary: Menghapus user berdasarkan ID
 *     tags: [Users]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID pengguna
 *     responses:
 *       200:
 *         description: User berhasil dihapus
 *       404:
 *         description: User tidak ditemukan
 *       500:
 *         description: Terjadi kesalahan pada server
 */
router.delete('/:id', userController.deleteUser);

module.exports = router;
