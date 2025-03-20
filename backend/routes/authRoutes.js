const express = require('express');
const router = express.Router();
const authController = require('../controller/authController');

/**
 * @swagger
 * tags:
 *   name: Authentication
 *   description: API untuk autentikasi pengguna
 */

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Membuat akun baru
 *     tags: [Authentication]
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
 *               - nomorTelepon
 *             properties:
 *               name:
 *                 type: string
 *                 example: John Doe
 *               email:
 *                 type: string
 *                 example: johndoe@gmail.com
 *               password:
 *                 type: string
 *                 example: mypassword
 *               nomorTelepon:
 *                 type: string
 *                 example: "08123456789"
 *               alamat:
 *                 type: string
 *                 example: "london inggris"
 *     responses:
 *       201:
 *         description: Akun berhasil dibuat
 *       400:
 *         description: Email sudah digunakan
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/register', authController.register);

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Login ke akun
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 example: johndoe@gmail.com
 *               password:
 *                 type: string
 *                 example: mypassword
 *     responses:
 *       200:
 *         description: Login berhasil
 *       401:
 *         description: Password salah
 *       404:
 *         description: User tidak ditemukan
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/login', authController.login);

/**
 * @swagger
 * /api/auth/forgot-password:
 *   post:
 *     summary: Mengatur ulang password pengguna
 *     tags: [Authentication]
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
 *                 example: johndoe@gmail.com
 *               password:
 *                 type: string
 *                 example: mypassword
 *     responses:
 *       200:
 *         description: Password baru telah dibuat
 *       404:
 *         description: Email tidak ditemukan
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/forgot-password', authController.forgotPassword);

module.exports = router;
